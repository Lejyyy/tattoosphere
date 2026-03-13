class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking

  # GET /bookings/:booking_id/payment/new
  def new
    @tatoueur = @booking.tatoueur
  end

  # GET /bookings/:booking_id/payment/bank_transfer
  def bank_transfer
    @tatoueur = @booking.tatoueur

    unless @tatoueur.bank_details_complete?
      redirect_to booking_path(@booking),
                  alert: "Le tatoueur n'a pas encore renseigné ses coordonnées bancaires." and return
    end

    if @booking.deposit_paid?
      redirect_to booking_path(@booking),
                  alert: "L'acompte a déjà été payé pour cette réservation." and return
    end

    @booking.update(payment_method: "bank_transfer")
  end

  # POST /bookings/:booking_id/payment/confirm_transfer
  def confirm_transfer
    unless current_user.tatoueur == @booking.tatoueur
      redirect_to booking_path(@booking), alert: "Non autorisé." and return
    end

    if @booking.deposit_paid?
      redirect_to booking_path(@booking), alert: "Ce virement a déjà été confirmé." and return
    end

    if @booking.update(
        deposit_paid:         true,
        deposit_paid_at:      Time.current,
        deposit_confirmed_at: Time.current,
        status:               "confirmed"
      )
      BookingMailer.deposit_confirmed(@booking).deliver_later
      BookingMailer.invoice(@booking).deliver_later
      redirect_to booking_path(@booking), notice: "Virement confirmé. La réservation est validée."
    else
      redirect_to booking_path(@booking), alert: "Une erreur est survenue."
    end
  end

  private

  def set_booking
    # Le client accède uniquement à ses propres bookings
    # Le tatoueur peut accéder aux bookings qui le concernent
    if current_user.tatoueur.present?
      @booking = Booking.find(params[:booking_id])
    else
      @booking = current_user.bookings.find(params[:booking_id])
    end
  end
end
