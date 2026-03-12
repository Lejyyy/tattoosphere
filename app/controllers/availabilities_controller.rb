class AvailabilitiesController < ApplicationController
  before_action :set_tatoueur

  def index
    @availabilities = @tatoueur.availabilities.order(:day_of_week)
    @availability = Availability.new
  end

  def create
    @availability = @tatoueur.availabilities.new(availability_params)
    if @availability.save
      redirect_to tatoueur_availabilities_path(@tatoueur), notice: "Disponibilité ajoutée"
    else
      @availabilities = @tatoueur.availabilities.order(:day_of_week)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @tatoueur.availabilities.find(params[:id]).destroy
    redirect_to tatoueur_availabilities_path(@tatoueur), notice: "Disponibilité supprimée"
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
  end

  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time)
  end
end
