class Admin::DashboardController < Admin::BaseController
  def index
    @users_count     = User.count
    @tatoueurs_count = Tatoueur.count
    @shops_count     = Shop.count
    @pending_tatoueurs = Tatoueur.where(verification_status: "pending")
    @pending_shops     = Shop.where(is_active: false)
    @recent_users      = User.order(created_at: :desc).limit(5)
  end
end
