class MediasController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    if params[:shop_id]
      @owner = Shop.find(params[:shop_id])
      @medias = @owner.medias
    elsif params[:tatoueur_id]
      @owner = Tatoueur.find(params[:tatoueur_id])
      @medias = @owner.medias
    end
  end
end
