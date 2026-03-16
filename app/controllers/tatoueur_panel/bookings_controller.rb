class TatoueurPanel::BookingsController < TatoueurPanel::BaseController
  before_action :set_booking, only: [ :show, :update ]

  def index
    @bookings = current_tatoueur.bookings
                                 .includes(:user, :shop)
                                 .order(date: :desc)
    @bookings = @bookings.where(status: params[:status]) if params[:status].present?
    @filter   = params[:status] || "all"
    @counts   = Booking::STATUSES.index_with { |s|
      current_tatoueur.bookings.where(status: s).count
    }
  end

  def show; end

  def update
    case params[:action_type]
    when "confirm"
      @booking.update(status: "confirmed")
      redirect_to tatoueur_panel_booking_path(@booking), notice: "Réservation confirmée ✅"
    when "cancel"
      @booking.update(status: "cancelled", cancellation_reason: params[:reason],
                      cancelled_at: Time.current)
      redirect_to tatoueur_panel_booking_path(@booking), notice: "Réservation annulée."
    when "done"
      @booking.update(status: "done")
      redirect_to tatoueur_panel_booking_path(@booking), notice: "Marquée comme terminée."
    end
  end

  private
  def set_booking
    @booking = current_tatoueur.bookings.find(params[:id])
  end
end
