class MyDevise::RegistrationsController < Devise::RegistrationsController

	  def after_inactive_sign_up_path_for(resource)
	    flash[:notice] = "Signed up... but need to confirm email address: #{resource.email}"
	    session[:temp_email] = resource.email
	    signed_up_confirm_path
	  end

	  def after_sign_in_path_for(resource)
	  	flash[:notice] = "Signed In Successfully"
  	 	bg_checks_path 
	  end

	  def create
	    build_resource(sign_up_params)
	    resource.build_individual(sign_up_params[:individual_attributes])
	    # this line is so we can build the User using strong parameters in method user_params
	    #@user = User.new(user_params)

	    resource_saved = resource.save
	    yield resource if block_given?
	    if resource_saved
#------------------------------------------------------------------------------
# The  below code is how Memberships is identified by a temp Individuals first_name
# which is set as a future User's email and assigns all Memberships to the new Indiv_id after sign up
#------------------------------------------------------------------------------
			indiv_Objects = Individual.where(f_name: @user.email)
			indiv_ids = []
			membership_ids = []
			indiv_Objects.each do |indiv|
				indiv_ids << indiv.id
			end
			indiv_ids.each do |i_id|
				membership_ids << Membership.find_by(individual_id: i_id).id
			end

			unless indiv_ids.empty?
				# By here should have populated indiv_ids and membership_ids
				
				# Note 1: membership_ids and indiv_ids should be the same size because currently in the Org
					# show page a new Membership and Indiv is created (thus a new Indiv id created for each new Indiv)
				# Note 2: where returns Active Record relation (basically an array) even if there is only 1 object 
					# that meets the criteria, BUT find_by always returns the single object itself
				indiv_ids.each do |i_id|
					Individual.delete(i_id)
				end
				# here all temp Indivs deleted, so now there are Membership objects with
					# their individual_id foreign keys pointing to a nil object
				
				# Below look through mem_ids, find the Membership with that id, 
					# assign that membership to the id of the Individual that just signed up
				indiv_of_new_user = resource.individual.id
				membership_ids.each do |m_id|
					@m = Membership.find_by_id(m_id)
					@m.individual_id = indiv_of_new_user
					@m.save
				end
			end
#------------------------------------------------------------------------------

	      if resource.active_for_authentication?
	      	if resource.confirmed?
	        	set_flash_message :notice, :signed_up if is_flashing_format?
	        	sign_up(resource_name, resource)
	        	puts "Confirmed and Signing Up"
	        	respond_with resource, location: after_sign_up_path_for(resource)
	      	else
	      		puts "Not confirmed. Should be at inactive sign up"
	      		respond_with resource, location: after_inactive_sign_up_path_for(resource)
	      	end

	      else
	        expire_data_after_sign_in!
	        puts "Not confirmed. Should be first time"
	        respond_with resource, location: after_inactive_sign_up_path_for(resource)
	      end
	    else
	    	if resource.confirmed?
				puts "Resource not saved? Signing in normal"
	    		clean_up_passwords resource
	    		expire_data_after_sign_in!
	    		respond_with resource, location: after_sign_in_path_for(resource)
	    	else
	    		respond_with resource, location: after_inactive_sign_up_path_for(resource)
	    	end
	    end

	  end

	 private
	 def user_params
	 	params.require(:user).permit(:email, :password, :password_confirmation, :encrypted_password, :salt, individual_attributes: [:f_name, :l_name, :role])
	 end
end