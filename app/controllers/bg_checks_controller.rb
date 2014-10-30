class BgChecksController < ApplicationController
  load_and_authorize_resource
  before_action :set_bg_check, only: [:show, :edit, :update, :destroy]

  def new
    @bg_check = BgCheck.new
    @issues = @bg_check.issues
  end

  def edit
    @issues = @bg_check.issues
  end

  # GET /bg_checks
  # GET /bg_checks.json
  def index
    if current_user.admin?
      @bg_checks = BgCheck.all.joins(:individual).order('l_name, f_name')
    else
      redirect_to current_user.individual.bg_check
    end
  end

  # POST /bg_checks
  # POST /bg_checks.json
  def create
    
    @bg_check = BgCheck.new(bg_check_params)

    if !current_user.admin?
      @bg_check.individual_id = current_user.individual.id 
    end

    respond_to do |format|
      if @bg_check.save

        format.html { redirect_to bg_check_path(@bg_check), notice: 'Bg check was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bg_check }
      else
        format.html { render action: 'new' }
        format.json { render json: @bg_check.errors, status: :unprocessable_entity }
      end
    end
  end

  def show  
    unless current_user.admin?
      unless current_user.individual.bg_check.id == @bg_check.id
        redirect_to '/restricted_access', notice: "Cannot access this background check."
      end
    end
  end

  # PATCH/PUT /bg_checks/1
  # PATCH/PUT /bg_checks/1.json
  def update
    respond_to do |format|
      if @bg_check.update(bg_check_params)
        format.html { redirect_to bg_check_path(@bg_check), notice: 'Bg check was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bg_check.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bg_checks/1
  # DELETE /bg_checks/1.json
  def destroy
    @bg_check.destroy
    respond_to do |format|
      format.html { redirect_to bg_checks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bg_check
      @bg_check = BgCheck.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bg_check_params
      params.require(:bg_check).permit(:date_requested, :status, :criminal_date, :child_abuse_date, :individual_id) 
    end
end
