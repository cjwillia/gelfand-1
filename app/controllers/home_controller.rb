class HomeController < ApplicationController
    def index
    	@all = BgCheck.all # so BgCheck.all query done once
    	@bgChecks_requested = @all.requested
    	@bgChecks_pCriminal = @all.passed_criminal
    	@bgChecks_pChildAbuse = @all.passed_child_abuse
    	@bgChecks_nCleared = @all.not_cleared
    	@bgChecks_expired = @all.expired

        render 'home/index'
    end

    def signed_up_confirm
        render 'home/sign_up_confirm'
    end
end