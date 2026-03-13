class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking

  # Choisir le moyen de paiement
  def new
    @tatoueur = @booking.tatoueur
  end

  # Virement bancaire — afficher les coordonnées
  def bank_transfer
    @tatoueur = @booking.tatoueur
    unless @tatoueur.bank_details_complete?
      redirect_to booking_path(@booking),
                  alert: "Le tatoueur n'a pas encore renseigné ses coordonnées bancaires." and return
    end
    @booking.update(payment_method: "bank_transfer")
  end

  # Tatoueur confirme réception du virement
  def confirm_transfer
    unless current_user.tatoueur? && current_user.tatoueur == @booking.tatoueur
      redirect_to booking_path(@booking), alert: "Non autorisé." and return
    end

    if @booking.update(
        deposit_paid:         true,
        deposit_paid_at:      Time.current,
        deposit_confirmed_at: Time.current,
        status:               "confirmed"
      )
      BookingMailer.invoice(@booking).deliver_later
      redirect_to booking_path(@booking),
                  notice: "✅ Virement confirmé ! La réservation est validée."
    else
      redirect_to booking_path(@booking), alert: "Une erreur est survenue."
    end
  end

  private

  def set_booking
    # Sécurité — un user ne peut accéder qu'à ses propres réservations
    # Exception pour le tatoueur qui confirme le virement
    if current_user.tatoueur?
      @booking = Booking.find(params[:booking_id])
    else
      @booking = current_user.bookings.find(params[:booking_id])
    end
  end
end
