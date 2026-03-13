class PaypalOnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_tatoueur

  def new
    # Générer le lien d'onboarding PayPal
    token   = PayPalClient.access_token
    uri     = URI("#{PayPalClient.base_url}/v2/customer/partner-referrals")

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{token}"
    req["Content-Type"]  = "application/json"
    req.body = {
      tracking_id:      "tatoueur_#{current_user.tatoueur.id}",
      partner_config_override: {
        return_url: paypal_onboarding_callback_url,
        return_url_description: "Retour sur Tattoosphere"
      },
      operations: [ {
        operation:            "API_INTEGRATION",
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
      products:    [ "EXPRESS_CHECKOUT" ],
      legal_consents: [ { type: "SHARE_DATA_CONSENT", granted: true } ]
    }.to_json

    res  = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }
    data = JSON.parse(res.body)

    # Lien vers lequel rediriger le tatoueur
    @onboarding_url = data["links"]
                        &.find { |l| l["rel"] == "action_url" }
                        &.dig("href")

    if @onboarding_url
      redirect_to @onboarding_url, allow_other_host: true
    else
      redirect_to edit_tatoueur_path(current_user.tatoueur),
                  alert: "Impossible de générer le lien PayPal."
    end
  end

  def callback
    merchant_id = params[:merchantId] || params[:merchant_id]

    if merchant_id.present?
      current_user.tatoueur.update(
        paypal_merchant_id: merchant_id,
        paypal_onboarded:   true
      )
      redirect_to edit_tatoueur_path(current_user.tatoueur),
                  notice: "✅ Votre compte PayPal est bien connecté !"
    else
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
end
