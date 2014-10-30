class OrganizationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_organization, only: [:show, :update, :destroy]


  # Need new and edit to get individiuals
  # wasnt sure how to combine code for both these actions
  def new
    @individuals = Individual.alphabetical.reject!{|i| i.organizations.include?(@organization) }
  end

  def edit
    @individuals = Individual.alphabetical.reject!{|i| i.organizations.include?(@organization) }
  end

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
    #                 - may be good to have 
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

    # only purpose of this loop: so duplicate temp indivs for same email not added 
        # Ex: john@andrew.cmu.edu added by Gelfand admin and john@andrew.cmu.edu may be added by org Manage
    not_in_app.each do |email|
        @indiv = Individual.find_by f_name: email
        # delete email if there is already a temp indiv
        if (!@indiv.nil?)
            not_in_app.delete(email)
        end
    end
        
    # Have to do this because even though user may be in app, he/she may already be member of organization
    #     Ex: jack is in app and part of SigEp, but orgHead types in jack@yahoo.com
    #     If dont have below exclusion, then jack will get added into SigEp for 2nd time
    # First have to map existing_member_ids to integers instead of "12" 
    existing_member_ids = existing_member_ids.map{|num| num.to_i}
    in_app = in_app - existing_member_ids

    # Add those in app from multiple email select
    in_app.each do |id|
        all_new_unique_mem_ids << id
    end

    # May have duplicate values due to selecting from regular non-email multiple select and email multiple select
    all_new_unique_mem_ids.uniq!

    # Make memberships for those already in system
    all_new_unique_mem_ids.each do |id|
      @organization.individuals << Individual.find(id)
    end


    # Sending the email using @orgMailer    

    @orgMailer = OrganizationMailer.new
    @orgMailer.org_name = @organization.name
    @orgMailer.NOTICE = "You have been temporarily given a Membership to \"#{@organization.name}\". To officially be in the system, sign up at: http://localhost:3000/users/sign_up"

    # perform stuff for each email
    not_in_app.each do |email_of_single|
        # Recall: not_in_app only has users not in system

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
            # make the membership
            @membership = Membership.new
            @membership.organization_id = @organization.id
            @membership.individual_id = @indiv.id
            @membership.save
        #---------------------------------------------------------------------
        
        if !@orgMailer.deliver
            redirect_to edit_organization_path(org_id)
            flash[:error] = 'Could not send notice.'
        end

    end
      
=begin

Notice will be:
Added: all_new_unique_mem_ids
Sent notice to: not_in_app's
Improper emails entered: bad_email's
  - Emails that didn’t pass validation test
  - Dont have this yet (Not necessary?)
=end

    # Make the notice
      notice_string = ""
      not_in_app.each do |email|
        notice_string+=(email+", ")
      end
      
      if (!not_in_app.empty?)
          notice_string = "Sent notice to: "+notice_string
          # take out last comma
          notice_string = notice_string.at(0..-3)
      end


      # add regular member (not sending email)
      if (!all_new_unique_mem_ids.empty?)
          if (not_in_app.empty?)
              notice_string += "No members were requested"
          end

          notice_string += " | " # need divider if not_in_app empty / not empty

          notice_string = notice_string + "Added member(s): " 
          # put all_new_unique_mem_ids into notice string
          all_new_unique_mem_ids.each do |id|
              notice_string += ((Individual.find(id)).proper_name+", ")
          end
          # take out last comma
          notice_string = notice_string.at(0..-3)
      end

    # if a regular update to Organization
    if (not_in_app.empty? and all_new_unique_mem_ids.empty?)
        notice_string = "Organization succesfully updated -- No new members were able to be added or requested."
    end

    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: notice_string }
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
