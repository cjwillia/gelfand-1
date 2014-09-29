class NewSessionsController < Devise::SessionsController

	def after_inactive_sign_up_path_for(resource)
	    flash[:notice] = "Signed up... but need to confirm email address: #{resource.email}"
	    session[:temp_email] = resource.email
	    signed_up_confirm_path
	end

	def new
		self.resource = resource_class.new(sign_in_params)
    	clean_up_passwords(resource)
    	if resource.confirmed?
    		respond_with(resource, serialize_options(resource))
    	else
    		respond_with resource, location: after_inactive_sign_up_path_for(resource)
    	end
	end

	def create
		self.resource = warden.authenticate!(auth_options)
    	set_flash_message(:notice, :signed_in) if is_flashing_format?
    	sign_in(resource_name, resource)
    	yield resource if block_given?
    	if resource.confirmed?
    		#puts "somehow confirmed"
    		respond_with resource, location: after_sign_in_path_for(resource)
    	else
    		#puts "not confirmed"
    		respond_with resource, location: after_inactive_sign_up_path_for(resource)
    	end
	end	

	def destroy
		super
	end
end
