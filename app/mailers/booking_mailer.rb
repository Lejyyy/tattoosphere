class BookingMailer < ApplicationMailer
  default from: "noreply@tattoosphere.com"

  # ================================
  # CONFIRMATION
  # ================================
  def confirmation(booking)
    @booking  = booking
    @user     = booking.user
    @tatoueur = booking.tatoueur
    @shop     = booking.shop

    mail(
      to:      @user.email,
      subject: "✅ Confirmation de votre réservation — #{@tatoueur.nickname}"
    )
  end

  # ================================
  # FACTURE PDF
  # ================================
  def invoice(booking)
    @booking  = booking
    @user     = booking.user
    @tatoueur = booking.tatoueur

    # Générer le PDF
    pdf = InvoicePdf.new(@booking)
    attachments["facture_#{@booking.id}.pdf"] = pdf.render

    mail(
      to:      @user.email,
      subject: "🧾 Facture acompte — Réservation ##{@booking.id}"
    )
  end

  # ================================
  # RAPPEL 24H AVANT
  # ================================
  def reminder(booking)
    @booking  = booking
    @user     = booking.user
    @tatoueur = booking.tatoueur
    @shop     = booking.shop

    mail(
      to:      @user.email,
      subject: "⏰ Rappel — Votre rendez-vous demain avec #{@tatoueur.nickname}"
    )
  end

  # ================================
  # ANNULATION
  # ================================
  def cancellation(booking)
    @booking  = booking
    @user     = booking.user
    @tatoueur = booking.tatoueur

    mail(
      to:      @user.email,
      subject: "❌ Annulation de votre réservation ##{@booking.id}"
    )
  end
end
