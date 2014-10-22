class IssuesController < ApplicationController
  def new
  end

  def create
  	@issue = Issue.new(issues_params)

  	respond_to do |format|
  		if @issue.save
  			BgCheck.find(@issue.bg_check_id).issues << @issue
  			format.js {}
  		else
  			redirect_to root_url, notice: "dat issue ain't save, mang."
  		end
  	end
  end

  def resolve

  end

  def destroy
  	@issue.destroy
  	respond_to do |format|
  		format.js {}
  		format.html {
  			redirect_to bg_checks_path, notice: "Issue Deleted"
  		}
  	end
  end

  private

  def set_issue
  	@issue = Issue.find(params[:id])
  end

  def issues_params
  	params.require(:issue).permit(:category, :description, :bg_check_id)
  end
end
