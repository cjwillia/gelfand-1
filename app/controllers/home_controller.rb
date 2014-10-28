class HomeController < ApplicationController
    def index
        if current_user.admin?
            redirect_to bg_checks_path
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