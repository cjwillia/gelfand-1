class HomeController < ApplicationController
    def index
    	@bgChecks_req = BgCheck.all.requested
    	@bgChecks_pCriminal = BgCheck.all.passed_criminal
        render 'home/index'
    end
end