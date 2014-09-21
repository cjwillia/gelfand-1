class HomeController < ApplicationController
    def index
        render 'home/index'
    end

    def signed_up_confirm
        render 'home/sign_up_confirm'
    end
end