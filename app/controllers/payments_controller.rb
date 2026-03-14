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
                  alert: "L'acompte a déjà été payé." and return
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
      redirect_to booking_path(@booking), notice: "Virement confirmé. La réservation est validée."
    else
      redirect_to booking_path(@booking), alert: "Une erreur est survenue."
    end
  end

  # POST /bookings/:booking_id/payment/paypal/create_order
  def create_paypal_order
    if @booking.deposit_paid?
      render json: { error: "Acompte déjà payé." }, status: :unprocessable_entity and return
    end

    unless @booking.tatoueur.paypal_onboarded?
      render json: { error: "Le tatoueur n'a pas connecté son compte PayPal." }, status: :unprocessable_entity and return
    end

    request = PayPalCheckoutSdk::Orders::OrdersCreateRequest.new
    request.request_body({
      intent: "CAPTURE",
      purchase_units: [ {
        amount: {
          currency_code: "EUR",
          value:         format("%.2f", @booking.deposit_amount)
        },
        payee: {
          merchant_id: @booking.tatoueur.paypal_merchant_id
        },
        description: "Acompte réservation – #{@booking.tatoueur.nickname}"
      } ]
    })

    response = PayPalClient.client.execute(request)
    render json: { id: response.result.id }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /bookings/:booking_id/payment/paypal/capture_order
  def capture_paypal_order
    request  = PayPalCheckoutSdk::Orders::OrdersCaptureRequest.new(params[:order_id])
    response = PayPalClient.client.execute(request)

    if response.result.status == "COMPLETED"
      @booking.update!(
        deposit_paid:         true,
        deposit_paid_at:      Time.current,
        deposit_confirmed_at: Time.current,
        payment_method:       "paypal",
        paypal_order_id:      response.result.id,
        status:               "confirmed"
      )
      render json: { status: "success" }
    else
      render json: { error: "Paiement non complété." }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_booking
    if current_user.tatoueur.present?
      @booking = Booking.find(params[:booking_id])
    else
      @booking = current_user.bookings.find(params[:booking_id])
    end
  end
end
