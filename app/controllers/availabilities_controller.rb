class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tatoueur
  before_action :authorize_tatoueur!

  # GET /tatoueurs/:tatoueur_id/availabilities
  def index
    @availabilities = @tatoueur.availabilities.order(:day_of_week)
    @availability   = Availability.new
  end

  # POST /tatoueurs/:tatoueur_id/availabilities
  def create
    @availability = @tatoueur.availabilities.new(availability_params)
    if @availability.save
      redirect_to tatoueur_availabilities_path(@tatoueur), notice: "Disponibilité ajoutée."
    else
      @availabilities = @tatoueur.availabilities.order(:day_of_week)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /tatoueurs/:tatoueur_id/availabilities/:id
  def destroy
    @tatoueur.availabilities.find(params[:id]).destroy
    redirect_to tatoueur_availabilities_path(@tatoueur), notice: "Disponibilité supprimée."
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
  end

  def authorize_tatoueur!
    unless current_user.tatoueur == @tatoueur || current_user.admin?
      redirect_to tatoueur_path(@tatoueur), alert: "Vous n'êtes pas autorisé à effectuer cette action."
    end
  end

  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time)
  end
end
