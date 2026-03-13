class TatoueurMailer < ApplicationMailer
  # Email de confirmation de soumission
  def verification_submitted(tatoueur)
    @tatoueur = tatoueur
    mail(
      to:      @tatoueur.email,
      subject: "Votre demande de vérification a bien été reçue"
    )
  end

  # Email d'approbation
  def verification_approved(tatoueur)
    @tatoueur = tatoueur
    mail(
      to:      @tatoueur.email,
      subject: "Félicitations, votre profil est maintenant vérifié ✓"
    )
  end

  # Email de rejet
  def verification_rejected(tatoueur, reason)
    @tatoueur = tatoueur
    @reason   = reason
    mail(
      to:      @tatoueur.email,
      subject: "Votre demande de vérification n'a pas été acceptée"
    )
  end
end
