class Admin::DashboardController < Admin::BaseController
  def index
    @pending_count   = Tatoueur.where(verification_status: "pending").count
    @tatoueurs_count = Tatoueur.where(is_active: true).count
    @shops_count     = Shop.where(is_active: true).count
    @bookings_count  = Booking.count
  end
end
