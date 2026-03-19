class Tatoueurs::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tatoueur

  def new
    @booking = Booking.new
    @shop    = @tatoueur.shops.first # shop par défaut si existant, nil sinon
    @slots   = []
    authorize @booking
  end

  def create
    @booking          = Booking.new(booking_params)
    @booking.user     = current_user
    @booking.tatoueur = @tatoueur
    @booking.shop     = @tatoueur.shops.first # nil si pas de shop
    @slots            = generate_slots(@tatoueur.id)
    authorize @booking

  if @booking.save
    BookingMailer.confirmation(@booking).deliver_later
    msg = @booking.date? ? "Réservation créée." : "Demande envoyée — la date sera définie avec #{@tatoueur.nickname}."
    redirect_to @booking, notice: msg
  end
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
  end

  def generate_slots
    slots = []
    @tatoueur.availabilities.each do |a|
      next unless a.start_time && a.end_time
      cur = a.start_time.hour * 60 + a.start_time.min
      fin = a.end_time.hour   * 60 + a.end_time.min
      while cur < fin
        slots << format("%02d:%02d", cur / 60, cur % 60)
        cur += 30
      end
    end
    slots.uniq.sort
  end

  def booking_params
    params.require(:booking).permit(
      :date, :description, :price_estimated, :start_time, :end_time
    )
  end
end
