class AffiliationsController < ApplicationController

  def index
  	@affiliations = Affiliation.all
  end

  def new
    unless params[:org_id].nil?
      @affiliation = Affiliation.new
      @program = Program.new
      @affiliation.organization_id = params[:org_id]
      @affiliation.program_id = @program.id
    else
      redirect_to '/', notice: "Permissions Error: Requires Organization Leadership"
    end
  end

  # This is a hacky synonym for "create" for the new program creation
  def start
    @affiliation = Affiliation.new(affiliation_params)
    @program = Program.new(program_params)
  end

  def create
    @affiliation = Affiliation.new(affiliation_params)
    if @affiliation.save!
      # if saved to database
      org_name = Organization.find(@affiliation.organization_id).name
      flash[:notice] = "Successfully created affiliation with #{org_name}."
      
      # if there is a key 'fromOrgShowPage' in the params, then redirect to org_show page
        # else show program page
          if !params["fromOrgShowPage"].nil?  
            redirect_to organization_path(@affiliation.organization_id)
          else
            redirect_to program_path(@affiliation.program_id)
        end
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  # DELETE
  # DELETE
  def destroy
    org_id = params[:organization_id]
    @affiliation = Affiliation.find(:first, 
                          :conditions => [ "organization_id = ? AND program_id = ?", org_id, params[:program_id]]) 

    @affiliation.destroy
    respond_to do |format|
      format.html { redirect_to organization_path(org_id) }
      format.json { head :no_content }
    end
  end


  private
  def affiliation_params
    params.require(:affiliation).permit(:organization_id, :program_id, :description, :followed_process, :ownership)
  end

  def program_params
    params.require(:program).permit(:name, :description, :num_minors, :num_adults_supervising, :start_date, :end_date)
  end

end