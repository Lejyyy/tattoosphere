class OnboardingController < ApplicationController
  before_action :authenticate_user!

  # GET /onboarding/tatoueur
  def tatoueur
    # Crée ou retrouve le funnel
    @funnel = current_user.onboarding_funnel ||
              current_user.create_onboarding_funnel!(kind: "tatoueur", step: "clicked")
    @funnel.update!(kind: "tatoueur") if @funnel.kind != "tatoueur"
  end

  # GET /onboarding/shop
  def shop
    @funnel = current_user.onboarding_funnel ||
              current_user.create_onboarding_funnel!(kind: "shop", step: "clicked")
    @funnel.update!(kind: "shop") if @funnel.kind != "shop"
  end

  # POST /onboarding/tatoueur
  def submit_tatoueur
    funnel = current_user.onboarding_funnel ||
             current_user.create_onboarding_funnel!(kind: "tatoueur", step: "clicked")

    # Crée ou met à jour le profil tatoueur (invisible jusqu'à abonnement)
    tatoueur = current_user.tatoueur || current_user.build_tatoueur
    tatoueur.assign_attributes(tatoueur_onboarding_params)
    tatoueur.is_active = false  # invisible jusqu'à abonnement

    if tatoueur.save
      # Attacher les documents si présents
      tatoueur.identity_document.attach(params[:tatoueur][:identity_document]) if params.dig(:tatoueur, :identity_document).present?
      tatoueur.hygiene_certificate.attach(params[:tatoueur][:hygiene_certificate]) if params.dig(:tatoueur, :hygiene_certificate).present?

      funnel.advance_to!("form_completed")

      # Planifier les relances
      OnboardingReminderJob.set(wait: 1.hour).perform_later(funnel.id, 1)
      OnboardingReminderJob.set(wait: 24.hours).perform_later(funnel.id, 2)
      OnboardingReminderJob.set(wait: 5.days).perform_later(funnel.id, 3)

      redirect_to subscription_path, notice: "Profil enregistré ! Choisissez votre abonnement pour le rendre visible."
    else
      render :tatoueur, status: :unprocessable_entity
    end
  end

  # POST /onboarding/shop
  def submit_shop
    funnel = current_user.onboarding_funnel ||
             current_user.create_onboarding_funnel!(kind: "shop", step: "clicked")

    shop = current_user.shop || current_user.build_shop
    shop.assign_attributes(shop_onboarding_params)
    shop.is_active = false

    if shop.save
      funnel.advance_to!("form_completed")

      OnboardingReminderJob.set(wait: 1.hour).perform_later(funnel.id, 1)
      OnboardingReminderJob.set(wait: 24.hours).perform_later(funnel.id, 2)
      OnboardingReminderJob.set(wait: 5.days).perform_later(funnel.id, 3)

      redirect_to subscription_path, notice: "Profil enregistré ! Choisissez votre abonnement pour le rendre visible."
    else
      render :shop, status: :unprocessable_entity
    end
  end

  private

  def tatoueur_onboarding_params
    params.require(:tatoueur).permit(
      :nickname, :address, :city, :zip_code,
      :siren, :bio
    )
  end

  def shop_onboarding_params
    params.require(:shop).permit(
      :name, :address, :city, :zip_code, :siren
    )
  end
end
