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
      if params[:search]
          # What about Last name?
          @bg_checks = BgCheck.joins(:individual).order('l_name, f_name').where('f_name LIKE ?', "%#{params[:search]}")
      elsif params[:filter]
        if params[:filter]=="all"
          @bg_checks = BgCheck.joins(:individual).alphabetical
        elsif params[:filter]=="submitted"
          @bg_checks = BgCheck.joins(:individual).submitted.alphabetical
        elsif params[:filter]=="passed_criminal"
          @bg_checks = BgCheck.joins(:individual).passed_criminal.alphabetical
        elsif params[:filter]=="passed_child_abuse"
          @bg_checks = BgCheck.joins(:individual).passed_child_abuse.alphabetical
        elsif params[:filter]=="picked_up"
          @bg_checks = BgCheck.joins(:individual).picked_up.alphabetical
        elsif params[:filter]=="has_issues"
          @bg_checks = BgCheck.joins(:individual).has_issues.alphabetical
        end
      else
          @bg_checks = BgCheck.joins(:individual).alphabetical
      end
    else
      redirect_to current_user.individual.bg_check
    end

=begin
    def self.search(search)
        if search
            self.individual
            where('status LIKE ?', "%#{search}")
        else
            scoped # can have all, but scope returns scoped result so can add more to it
        end
    end
=end
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
