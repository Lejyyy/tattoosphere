class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [ :show, :edit, :update, :destroy ]

  def index
    @bookings = policy_scope(Booking).order(date: :desc)
  end

def show
  authorize @booking
  respond_to do |format|
    format.html
    format.pdf do
      pdf = BookingPdf.new(@booking)
      send_data pdf.render,
                filename: "reservation_#{@booking.id}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end
  end
end

  def new
    @shop      = Shop.find(params[:shop_id])
    @tatoueurs = @shop.tatoueurs.where(is_active: true)
    @booking   = Booking.new
    @slots     = []
    authorize @booking
  end

  def create
    @shop      = Shop.find(params[:shop_id])
    @booking   = Booking.new(booking_params)
    @booking.user = current_user
    @booking.shop = @shop
    @tatoueurs = @shop.tatoueurs.where(is_active: true)
    @slots     = generate_slots(@booking.tatoueur_id)
    authorize @booking

    if @booking.save
      BookingMailer.confirmation(@booking).deliver_later
      redirect_to @booking, notice: "Réservation créée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @booking
  end

  def update
    authorize @booking
    if @booking.update(booking_params)
      redirect_to @booking, notice: "Réservation mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @booking
    unless @booking.cancellable?
      redirect_to @booking, alert: "Cette réservation ne peut plus être annulée." and return
    end
    @booking.update(
      status:              "cancelled",
      cancelled_at:        Time.current,
      cancellation_reason: params[:cancellation_reason]
    )
    redirect_to bookings_path, notice: "Réservation annulée."
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def generate_slots(tatoueur_id)
    return [] unless tatoueur_id.present?
    tatoueur = Tatoueur.find_by(id: tatoueur_id)
    return [] unless tatoueur

    slots = []
    tatoueur.availabilities.each do |a|
      next unless a.start_time && a.end_time
      current_minutes = a.start_time.hour * 60 + a.start_time.min
      end_minutes     = a.end_time.hour * 60 + a.end_time.min

      while current_minutes < end_minutes
        slots << format("%02d:%02d", current_minutes / 60, current_minutes % 60)
        current_minutes += 30
      end
    end
    slots.uniq.sort
  end

  def booking_params
    params.require(:booking).permit(
      :tatoueur_id, :date, :description,
      :price_estimated, :start_time, :end_time
    )
  end
end
