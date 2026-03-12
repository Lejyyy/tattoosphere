class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    @shops = Shop.where(is_active: true).limit(3)
    @tatoueurs = Tatoueur.where(is_active: true).limit(4)
    @events = Event.where(is_public: true).order(:start_date).limit(3)
  end
end