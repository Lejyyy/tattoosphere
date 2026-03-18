class OnboardingMailer < ApplicationMailer
  def reminder(funnel, number)
    @user   = funnel.user
    @funnel = funnel
    @number = number
    @kind   = funnel.kind == "tatoueur" ? "tatoueur" : "shop"

    subjects = {
      1 => "Votre profil #{@kind} est prêt — plus qu'un abonnement !",
      2 => "Vous étiez si proche… Activez votre profil #{@kind} 🖋️",
      3 => "Dernière chance : votre profil #{@kind} vous attend sur Tattoosphere"
    }

    mail(to: @user.email, subject: subjects[number])
  end
end
