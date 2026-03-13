class SocialsController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_owner

  # GET /shops/:shop_id/socials
  # GET /tatoueurs/:tatoueur_id/socials
  def index
    @socials = @owner.socials
  end

  private

  def set_owner
    if params[:shop_id]
      @owner = Shop.find(params[:shop_id])
    elsif params[:tatoueur_id]
      @owner = Tatoueur.find(params[:tatoueur_id])
    else
      redirect_to root_path, alert: "Ressource introuvable."
    end
  end
end
