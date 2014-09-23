class HomeController < ApplicationController
    def index
    	@all = BgCheck.all # so BgCheck.all query done once
    	@bgChecks_requested = @all.requested
    	@bgChecks_pCriminal = @all.passed_criminal
    	@bgChecks_pChildAbuse = @all.passed_child_abuse
        @bgChecks_underReview = @all.criminal_failed
    	@bgChecks_nCleared = @all.not_cleared
    	@bgChecks_expired = @all.expired.limit(30)

        render 'home/index'
    end
end