class ShopPanel::BookingsController < ShopPanel::BaseController
  before_action :set_booking, only: [ :show, :update ]

  def index
    @bookings = current_shop.bookings.includes(:user, :tatoueur).order(date: :desc)
    @bookings = @bookings.where(status: params[:status]) if params[:status].present?
    @filter   = params[:status] || "all"
    @counts   = Booking::STATUSES.index_with { |s|
      current_shop.bookings.where(status: s).count
    }
  end

  def show; end

  def update
    case params[:action_type]
    when "confirm"
      @booking.update(status: "confirmed")
      redirect_to shop_panel_booking_path(@booking), notice: "Réservation confirmée ✅"
    when "cancel"
      @booking.update(status: "cancelled", cancellation_reason: params[:reason],
                      cancelled_at: Time.current)
      redirect_to shop_panel_booking_path(@booking), notice: "Réservation annulée."
    end
  end

  private
  def set_booking
    @booking = current_shop.bookings.find(params[:id])
  end
end
