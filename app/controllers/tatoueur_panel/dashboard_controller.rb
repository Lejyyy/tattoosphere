class TatoueurPanel::DashboardController < TatoueurPanel::BaseController
  def index
    @bookings_count    = current_tatoueur.bookings.count
    @pending_bookings  = current_tatoueur.bookings.where(status: "pending")
    @upcoming_bookings = current_tatoueur.bookings
                                         .where(status: "confirmed")
                                         .where("date >= ?", Date.today)
                                         .order(date: :asc).limit(5)
    @reviews_count     = current_tatoueur.reviews.count
    @avg_rating        = current_tatoueur.reviews.average(:rating)&.round(1)
    @unread_count      = current_tatoueur.conversations
                                          .sum { |c| c.unread_count_for(current_user) rescue 0 }
    @recent_reviews    = current_tatoueur.reviews.order(created_at: :desc).limit(3).includes(:user)
  end

  def stats
    @bookings_by_month = current_tatoueur.bookings
                                          .where("date >= ?", 6.months.ago)
                                          .group_by { |b| b.date.strftime("%B %Y") }
                                          .transform_values(&:count)
    @revenue_estimate  = current_tatoueur.bookings
                                          .where(status: %w[confirmed done])
                                          .sum(:price_estimated)
    @top_styles        = current_tatoueur.tattoo_styles.map do |s|
      [ s.name, current_tatoueur.portfolio_items.joins(:tattoo_styles)
                               .where(tattoo_styles: { id: s.id }).count ]
    end.sort_by { |_, c| -c }
  end
end
