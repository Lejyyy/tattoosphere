class BlockedSlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tatoueur

  # POST /tatoueurs/:tatoueur_id/blocked_slots
  def create
    authorize @tatoueur, :update?
    data = JSON.parse(params[:blocked_data] || "[]")

    data.each do |entry|
      @tatoueur.blocked_slots.create!(
        date:       entry["date"],
        start_time: entry["start_time"],
        end_time:   entry["end_time"],
        reason:     entry["reason"].presence || "Indisponibilité"
      )
    end

    redirect_to tatoueur_availabilities_path(@tatoueur),
                notice: "Indisponibilités enregistrées."
  end

  # DELETE /tatoueurs/:tatoueur_id/blocked_slots/:id
  def destroy
    authorize @tatoueur, :update?
    @tatoueur.blocked_slots.find(params[:id]).destroy
    redirect_to tatoueur_availabilities_path(@tatoueur),
                notice: "Indisponibilité supprimée."
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
  end
end
