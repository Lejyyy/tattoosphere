class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [ :show, :edit, :update, :destroy ]

  # GET /bookings
  def index
    @bookings = policy_scope(Booking).order(date: :desc)
  end

  # GET /bookings/:id
  def show
    authorize @booking
  end

  # GET /shops/:shop_id/bookings/new
  def new
    @shop      = Shop.find(params[:shop_id])
    @tatoueurs = @shop.tatoueurs.where(is_active: true)
    @booking   = Booking.new
    authorize @booking
  end

  # POST /shops/:shop_id/bookings
  def create
    @shop    = Shop.find(params[:shop_id])
    @booking = Booking.new(booking_params)
    @booking.user = current_user
    @booking.shop = @shop
    authorize @booking

    if @booking.save
      BookingMailer.confirmation(@booking).deliver_later
      redirect_to @booking, notice: "Réservation créée."
    else
      @tatoueurs = @shop.tatoueurs.where(is_active: true)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /bookings/:id/edit
  def edit
    authorize @booking
  end

  # PATCH /bookings/:id
  def update
    authorize @booking

    if @booking.update(booking_params)
      redirect_to @booking, notice: "Réservation mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bookings/:id
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

  def booking_params
    params.require(:booking).permit(
      :tatoueur_id, :date, :description,
      :price_estimated, :start_time, :end_time
    )
  end
end
