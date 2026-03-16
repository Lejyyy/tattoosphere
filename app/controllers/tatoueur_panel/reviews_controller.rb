class TatoueurPanel::ReviewsController < TatoueurPanel::BaseController
  def index
    @reviews = current_tatoueur.reviews.includes(:user).order(created_at: :desc)
    @avg     = @reviews.average(:rating)&.round(1)
  end
end
