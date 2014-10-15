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
    # Essentially 3 parts
    #   Org multiple email add
    #   Org regular multiple add
    #   Org change in model (ie. name, description, etc)
    #   
    # Using 5 new arrays
    #   bad_emails    - improper emails, ie. john@@yahoo.com, john@yahoo, etc..
    #   good_emails   - these emails passed validate check
    #   not_in_app    - subset of good_emails - emails not in app
    #   in_app        - subset of good_emails - emails in app (will map this to ids)
    #   all_new_unique_mem_ids - add new_member_ids and those in_app, then remove duplicates
    
    bad_emails  = []
    good_emails = []
    not_in_app  = []
    in_app = []
    all_new_unique_mem_ids = []

        # THIS SECTION: populate new_member_ids from regular non-email multiple select
        member_ids = params[:organization][:individual_ids]
        member_ids.reject!(&:blank?) # only 1st element might come up as empty quotes, but doing for all just in case
        # member_ids may already be in the system, so need to subtract this set 
        #   from the set thats already in memberships.individuals  

        # need to_s since member_ids are strings and need to do when doing "-" on the arrays
        existing_member_ids = @organization.individuals.map{|indiv| indiv.id.to_s}
        new_member_ids = member_ids - existing_member_ids

    # Add ids from regular non-email multiple select
    new_member_ids.each do |id|
        all_new_unique_mem_ids << id
    end

    # get the string of emails, then split them into an array using comma delimiter
    @emails = (params[:organization][:new_emails]).split(',')

    # Validate all emails, then split them into good, bad group
    good_emails = @emails.find_all {|email| email =~ /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }
    bad_emails = @emails - good_emails

    # Separate associated indiv_ids in app from those that don't exist yet from list of good_emails (validated emails)
    good_emails.each do |email_of_single|
        @user = User.find_by email: email_of_single
        if (!@user.nil?)
            in_app << @user.individual.id
        else
            not_in_app << email_of_single
        end
    end

    # Add those in app from multiple email select
    in_app.each do |id|
        all_new_unique_mem_ids << id
    end

    # May have duplicate values due to selecting from regular non-email multiple select and email multiple select
    all_new_unique_mem_ids.uniq!

    # Make the memberships
    all_new_unique_mem_ids.each do |id|
      @organization.individuals << Individual.find(id)
    end

    @orgMailer = OrganizationMailer.new
    @orgMailer.org_name = @organization.name
    @orgMailer.NOTICE = "You have been temporarily given a Membership to \"#{@organization.name}\". To officially be in the system, sign up at: http://gelfand-gelfand.rhcloud.com/users/sign_up"
    
=begin

a - unique indiv ids in system, that are not part of org
not_in_app - emails for new prospective users

Notice will be:
Added: a's
Sent notice to: not_in_app's
Improper emails entered: bad_email's
  - Emails that didn’t pass validation test
=end

      org_id = @organization.id
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
                  return
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
        return
      end


    #params[:asdf] = asdf

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
