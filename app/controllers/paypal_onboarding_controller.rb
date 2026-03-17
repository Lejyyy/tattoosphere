class PaypalOnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_tatoueur

  # GET /paypal/onboarding
  def new
    token = PayPalClient.access_token
    uri   = URI("#{PayPalClient.base_url}/v2/customer/partner-referrals")

    req                  = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{token}"
    req["Content-Type"]  = "application/json"
    req.body             = build_referral_payload.to_json

    res  = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }
    data = JSON.parse(res.body)

    @onboarding_url = data["links"]
                        &.find { |l| l["rel"] == "action_url" }
                        &.dig("href")

    if @onboarding_url
      redirect_to @onboarding_url, allow_other_host: true
    else
      Rails.logger.error("[PayPal Onboarding] Réponse inattendue : #{res.body}")
      redirect_to edit_tatoueur_path(current_user.tatoueur),
                  alert: "Impossible de générer le lien PayPal. Veuillez réessayer."
    end
  rescue StandardError => e
    Rails.logger.error("[PayPal Onboarding] Erreur : #{e.message}")
    redirect_to edit_tatoueur_path(current_user.tatoueur),
                alert: "Une erreur est survenue lors de la connexion PayPal."
  end

  # GET /paypal/callback
  def callback
    merchant_id = params[:merchantId].presence || params[:merchant_id].presence

    if merchant_id
      current_user.tatoueur.update!(
        paypal_merchant_id: merchant_id,
        paypal_onboarded:   true
      )
      redirect_to edit_tatoueur_path(current_user.tatoueur),
                  notice: "Votre compte PayPal est bien connecté."
    else
      Rails.logger.warn("[PayPal Callback] merchantId manquant — params: #{params.to_unsafe_h}")
      redirect_to edit_tatoueur_path(current_user.tatoueur),
                  alert: "La connexion PayPal a échoué. Veuillez réessayer."
    end
  end

  private

  def ensure_tatoueur
    unless current_user.tatoueur?
      redirect_to root_path, alert: "Accès réservé aux tatoueurs."
    end
  end

  def build_referral_payload
    {
      tracking_id:             "tatoueur_#{current_user.tatoueur.id}",
      partner_config_override: {
        return_url:             paypal_onboarding_callback_url,
        return_url_description: "Retour sur Tattoosphere"
      },
      operations: [ {
        operation:                  "API_INTEGRATION",
        api_integration_preference: {
          rest_api_integration: {
            integration_method:  "PAYPAL",
            integration_type:    "THIRD_PARTY",
            third_party_details: {
              features: [ "PAYMENT", "REFUND" ]
            }
          }
        }
      } ],
      products:       [ "EXPRESS_CHECKOUT" ],
      legal_consents: [ { type: "SHARE_DATA_CONSENT", granted: true } ]
    }
  end
end
