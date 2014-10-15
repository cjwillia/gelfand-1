class OrganizationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.all.alphabetical
    @participant = Participant.new
    @users = User.all.map{|user| user} #Individual.all.map{|indiv| indiv.user.id}
    @names_from_users = []
    @users.each do |user|
        # if user does not have an individual, then just use email
        if user.individual.nil?
          @names_from_users << [user.email, user.id]
        else
          @names_from_users << [user.individual.name, user.id]
        end
    end
    @names_from_users.sort!
  end

  def show
    @organizatoin = Organization.find(params[:id])
    @affiliation = Affiliation.new
  end

  def org_overview
    @organizations = Organization.all
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
                # create an associated Org_user
                @org_user = OrgUser.new
                @org_user.organization_id = @organization.id
                @org_user.user_id = current_user.id
                @org_user.save

                # On default create a membership to the OrgUser/Admin/person_that_created_the_org
                @membership = Membership.new
                @membership.individual_id = current_user.individual.id
                @membership.organization_id = @organization.id
                @membership.save

        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render action: 'show', status: :created, location: @organization }
      else
        format.html { render action: 'new' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update

    # check orgMailer 
      @orgMailer = OrganizationMailer.new(params[:organization_mailer])
      @orgMailer.org_name = @organization.name
      @orgMailer.NOTICE = "You have been temporarily given a Membership to \"#{@organization.name}\". To officially be in the system, sign up at: http://gelfand-gelfand.rhcloud.com/users/sign_up"
      @orgMailer.nickname = "cool_name"
      @emails = @orgMailer.currently_registered_email.split(',')
      params[:asdf] = asdf

    member_ids = params[:organization][:individual_ids]
    member_ids.reject!(&:blank?) # only 1st element might come up as empty quotes, but doing for all just in case
    # member_ids may already be in the system, so need to subtract this set 
    #   from the set thats already in memberships.individuals  

    # need to_s since member_ids are strings and need to do when doing "-" on the arrays
    existing_member_ids = @organization.individuals.map{|indiv| indiv.id.to_s}
    new_member_ids = member_ids - existing_member_ids
    new_member_ids.each do |m|
      @organization.individuals << Individual.find(m)
    end

    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url }
      format.json { head :no_content }
    end
  end

  def send_sign_up_notice_if_no_indiv_exists
      # doing stuff here so take care of redundant code
      @orgMailer = OrganizationMailer.new(params[:organization_mailer])
      @emails = @orgMailer.currently_registered_email.split(',')
      # TO DO
      #   1. perform validation on each email in emails
      #       if 1 email is not proper, redirect back to org manage with error  
      #   2. For each email create memberships 
      #   
      org_id = params[:organization_id]

      # use this count variable to check how many emails were valid
      @count = 0
      # perform stuff for each email
      @emails.each do |email_of_single|
          @membership = Membership.new
          @membership.organization_id = org_id
          @user = User.find_by email: email_of_single
    

          # send notice if no User exists, 
          # if User exists make the Membership with existing Individual since if User exists, the
              # connected Individual must also exist because this happens when signing up
          if (!@user.nil?)
              @indiv = Individual.find_by user_id: @user.id
               @membership.individual_id = @indiv.id
               if @membership.save
                  redirect_to organization_path(org_id), notice: "Added member: #{@indiv.f_name}"
                  
               else
                  redirect_to edit_organization_path(org_id),  notice: "Could not add member."
                end
         
          else
                # this line pertinent -- before can deliver, need to change object's email to single email
                @orgMailer.currently_registered_email = email_of_single

                # making the temporary membership when an Admin user enters in an email
                #---------------------------------------------------------------------
                        # making the indiv for the temp membership
                        @indiv = Individual.new
                        @indiv.f_name = @orgMailer.currently_registered_email
                        @indiv.l_name = "Temp: " 
                        @indiv.role = 0
                        @indiv.save
                    @membership.individual_id = @indiv.id
                    @membership.save
                #---------------------------------------------------------------------
                
                if @orgMailer.deliver
                    @count = @count+1
                else
                  redirect_to edit_organization_path(org_id)
                  flash[:error] = 'Could not send notice.'
                end
          end 
      end
      # Only redirect if: we were able to deliver to all emails
      if @count == @emails.length
        notice_string = ""
        @emails.each do |email|
          notice_string+=(email+", ")
        end
        # take out last comma
        notice_string = notice_string.at(0..-3)
        # redirect to show page
        redirect_to organization_path(org_id), notice: "Notice sent to: "+notice_string
      end

  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    def individual_params
      params.require(:individual).permit(:id, :f_name, :l_name, :active, :contact_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:name, :is_partner, :description, :active, :department, :contact_id, memberships_attributes: [:id, :organization_id, :individual_id, :_destroy])
    end
end
