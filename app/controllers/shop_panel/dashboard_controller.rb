class ShopPanel::DashboardController < ShopPanel::BaseController
  def index
    @bookings_count    = current_shop.bookings.count
    @pending_bookings  = current_shop.bookings.where(status: "pending")
    @upcoming_bookings = current_shop.bookings
                                      .where(status: "confirmed")
                                      .where("date >= ?", Date.today)
                                      .order(date: :asc).limit(5)
    @tatoueurs_count   = current_shop.tatoueurs.count
    @unread_count      = current_shop.conversations
                                      .sum { |c| c.unread_count_for(current_user) rescue 0 }
    @events_count      = current_shop.events.where("start_date >= ?", Time.current).count
  end

  def stats
    @bookings_by_month = current_shop.bookings
                                      .where("date >= ?", 6.months.ago)
                                      .group_by { |b| b.date.strftime("%B %Y") }
                                      .transform_values(&:count)
    @revenue_estimate  = current_shop.bookings
                                      .where(status: %w[confirmed done])
                                      .sum(:price_estimated)
  end
end
