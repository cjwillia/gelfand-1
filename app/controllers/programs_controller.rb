class ProgramsController < ApplicationController
  load_and_authorize_resource
  before_action :set_program, only: [:edit, :update, :destroy]

  def new
    @program = Program.new
    if current_user.organizations.include?(Organization.find(params[:org_id]))
      @program.organizations << Organization.find(params[:org_id])
    else
      redirect_to "/restricted_access", notice: "Must be an organization leader and create from organization page."
    end
  end

  # POST /programs
  # POST /programs.json
  def create
    @program = Program.new(program_params)
    if @program.save
      redirect_to @program, notice: "Program created successfully"
    else
      render action: 'new'  
    end
  end

  # These controller actions are probably deprecated. Made them a while back -Cory

  # def individuals_list
  #   @program = Program.find(params[:id])
  #   @cleared = @program.cleared_participants
  #   @not_cleared = @program.uncleared_participants
  # end

  # def ongoing
  #   @ongoing = Program.current
  # end

  # def completed
  #   @completed = Program.completed
  # end

  # def upcoming
  #   @upcoming = Program.upcoming
  # end

  # GET /programs
  # GET /programs.json
  def index
    @programs = Program.all
    @upcoming_progs = Program.upcoming
    @in_progress = Program.current
  end

  def show
    @program = Program.find(params[:id])
    @affiliation = Affiliation.new
  end

  def edit
    if current_user.orgs
      @orgs = Organization.all
  end

  # PATCH/PUT /programs/1
  # PATCH/PUT /programs/1.json
  def update
    @newparticipants = params[:program][:individual_ids]
    @newparticipants.reject!(&:blank?)
    @newparticipants.each do |i|
      @program.individuals << Individual.find(i)
    end

    if @program.update(program_params)
      redirect_to @program, notice: 'Program was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    @program.destroy
    respond_to do |format|
      format.html { redirect_to programs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_program
      @program = Program.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def program_params
      params.require(:program).permit(:name, :description, :start_date, :end_date, :cmu_facilities, :off_campus_facilities, :num_minors, :num_adults_supervising, :irb_approval, :contact_id, :organizations, :organization_ids, :individual_ids, affiliations_attributes: [:id, :organization_id, :program_id, :description, :followed_process, :_destroy])
    end

    def affiliations_params
      params.require(:affiliations).permit(:organization_ids)
    end

end
