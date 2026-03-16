class BookingPdf
  include Prawn::View

  def initialize(booking)
    @booking = booking
    build
  end

  def build
    # En-tête
    fill_color "F5C500"
    text "TATTOOSPHERE", size: 28, style: :bold
    fill_color "888888"
    text "Confirmation de réservation", size: 12
    move_down 10

    # Ligne de séparation
    stroke_color "F5C500"
    stroke_horizontal_rule
    move_down 15

    # Infos réservation
    fill_color "FFFFFF"
    text "RÉSERVATION ##{@booking.id}", size: 14, style: :bold
    move_down 10

    data = [
      [ "Tatoueur",   @booking.tatoueur.nickname ],
      [ "Shop",       @booking.shop.name ],
      [ "Date",       @booking.date&.strftime("%d %B %Y") ],
      [ "Heure",      @booking.start_time&.strftime("%Hh%M") || "—" ],
      [ "Statut",     @booking.status ],
      [ "Acompte",    "#{@booking.deposit_amount} €" ],
      [ "Description", @booking.description || "—" ]
    ]

    table data, cell_style: { borders: [], padding: [ 4, 8 ], text_color: "CCCCCC", size: 11 } do
      column(0).font_style = :bold
      column(0).text_color = "F5C500"
    end

    move_down 20
    stroke_horizontal_rule
    move_down 10

    fill_color "555555"
    text "Tattoosphere — #{Date.today.year}", size: 9, align: :center
  end
end
