class BookingsController < ApplicationController
  before_action :set_booking, only: [ :show, :edit, :update, :destroy ]

  def index
    @bookings = policy_scope(Booking)
  end

  def show
    authorize @booking
  end

  def new
    @booking = Booking.new
    @shop = Shop.find(params[:shop_id])
    @tatoueurs = @shop.tatoueurs
    authorize @booking
  end

  def create
    @shop = Shop.find(params[:shop_id])
    @booking = Booking.new(booking_params)
    @booking.user = current_user
    @booking.shop = @shop
    authorize @booking
    if @booking.save
      redirect_to @booking, notice: "Réservation créée"
    else
      @tatoueurs = @shop.tatoueurs
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @booking
  end

  def update
    authorize @booking
    if @booking.update(booking_params)
      redirect_to @booking, notice: "Réservation mise à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @booking
    @booking.update(status: "cancelled")
    redirect_to bookings_path, notice: "Réservation annulée"
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:tatoueur_id, :date, :description, :price_estimated, :start_time, :end_time)
  end
end
