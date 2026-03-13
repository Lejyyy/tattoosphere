class InvoicePdf < Prawn::Document
  def initialize(booking)
    super(page_size: "A4", margin: 40)
    @booking  = booking
    @user     = booking.user
    @tatoueur = booking.tatoueur
    @shop     = booking.shop

    build
  end

  private

  def build
    header
    divider
    booking_details
    divider
    payment_details
    divider
    footer
  end

  def header
    text "TATTOOSPHERE", size: 24, style: :bold, color: "c9a84c"
    text "Facture d'acompte", size: 14, color: "666666"
    move_down 5
    text "Facture N° #{@booking.id} — #{Date.today.strftime('%d/%m/%Y')}",
         size: 10, color: "999999"
  end

  def divider
    move_down 15
    stroke_color "2a2a2a"
    stroke_horizontal_rule
    move_down 15
  end

  def booking_details
    text "DÉTAILS DE LA RÉSERVATION", size: 12, style: :bold
    move_down 10

    data = [
      [ "Client",    "#{@user.first_name} #{@user.last_name}" ],
      [ "Email",     @user.email ],
      [ "Tatoueur",  @tatoueur.nickname ],
      [ "Shop",      @shop.name ],
      [ "Adresse",   @shop.address ],
      [ "Date RDV",  @booking.date.strftime("%d/%m/%Y") ],
      [ "Horaire",   "#{@booking.start_time&.strftime('%H:%M')} — #{@booking.end_time&.strftime('%H:%M')}" ],
      [ "Statut",    @booking.status.upcase ]
    ]

    table(data, width: bounds.width) do
      cells.borders      = []
      cells.padding      = [ 4, 8 ]
      column(0).font_style = :bold
      column(0).width    = 120
    end
  end

  def payment_details
    text "DÉTAILS DU PAIEMENT", size: 12, style: :bold
    move_down 10

    data = [
      [ "Prix estimé",         "#{@booking.price_estimated} €" ],
      [ "Acompte réglé",       "#{@booking.deposit_amount} €" ],
      [ "Date de paiement",    @booking.deposit_paid_at&.strftime("%d/%m/%Y à %H:%M") || "-" ],
      [ "Référence PayPal",    @booking.paypal_payment_id || "-" ],
      [ "Reste à régler",      "#{(@booking.price_estimated.to_f - @booking.deposit_amount.to_f).round(2)} €" ]
    ]

    table(data, width: bounds.width) do
      cells.borders      = []
      cells.padding      = [ 4, 8 ]
      column(0).font_style = :bold
      column(0).width    = 160
      row(4).font_style  = :bold
    end
  end

  def footer
    move_down 20
    text "Merci de votre confiance !",
         size: 11, style: :italic, color: "c9a84c", align: :center
    move_down 5
    text "Ce document tient lieu de reçu pour l'acompte versé.",
         size: 9, color: "999999", align: :center
  end
end
