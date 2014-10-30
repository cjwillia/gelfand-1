class IssuesController < ApplicationController
	before_action :set_issue, only: [:resolve, :unresolve, :destroy]

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
		@issue.resolved = DateTime.now

		respond_to do |format|
			if @issue.save
				format.js {}
				format.html { redirect_to bg_checks_path, notice: "Issue successfully resolved" }
			else
				redirect_to @issue.bg_check, notice: "Error resolving issue"
			end
		end
	end

	def unresolve
		@issue.resolved = nil

		respond_to do |format|
			if @issue.save
				format.js {}
				format.html {}
			else
				redirect_to @issue.bg_check, notice: "Error unresolving issue"
			end
		end
	end

	def destroy
		@id = @issue.id
		respond_to do |format|
			if @issue.delete
				format.js {}
				format.html {
					redirect_to bg_checks_path, notice: "Issue Deleted"
				}
			else
				redirect_to @issue.bg_check notice: "Error Deleting Issue"
			end
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
