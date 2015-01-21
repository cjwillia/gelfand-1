class HomeController < ApplicationController
    def index
        # if user exists route to appropriate bg_check path
        if  current_user
            # use this to redirect to a new or existing bg_check for a user
            bg_c = current_user.individual.bg_check
            if current_user.admin?
                redirect_to bg_checks_path
            elsif (bg_c.nil?)
                redirect_to new_bg_check_path
            else
                redirect_to bg_check_path(bg_c)
            end
        else
            render 'home/index'
        end            
    end

    def signed_up_confirm
        render 'home/sign_up_confirm'
    end

    def restricted_access
        render 'home/restricted_access'
    end
end