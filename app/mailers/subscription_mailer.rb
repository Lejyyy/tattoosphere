class SubscriptionMailer < ApplicationMailer
  def confirmation(user, plan)
    @user = user
    @plan = plan
    mail(to: @user.email, subject: "Bienvenue sur l'offre #{plan.capitalize} — Tattoosphere")
  end

  def trial_ending(user)
    @user = user
    @trial_ends_at = user.subscription.trial_ends_at
    mail(to: @user.email, subject: "Votre essai gratuit se termine demain — Tattoosphere")
  end

  def payment_failed(user)
    @user = user
    mail(to: @user.email, subject: "⚠️ Échec du paiement de votre abonnement — Tattoosphere")
  end

  def expired(user)
    @user = user
    mail(to: @user.email, subject: "Votre abonnement Tattoosphere a expiré")
  end
end
