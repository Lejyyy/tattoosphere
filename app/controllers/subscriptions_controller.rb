class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # GET /subscriptions — page de choix du plan
  def index
    @current_subscription = current_user.subscription
  end

  # POST /subscriptions/checkout?plan=essentiel
  def checkout
    plan = params[:plan]
    config = Subscription::PLANS[plan]
    return redirect_to subscriptions_path, alert: "Plan invalide." unless config

    customer = find_or_create_stripe_customer

    session_params = {
      customer:   customer.id,
      mode:       "subscription",
      line_items: [ { price: config[:price_id], quantity: 1 } ],
      success_url: subscription_success_url(plan: plan),
      cancel_url:  subscriptions_url,
      metadata:    { user_id: current_user.id, plan: plan }
    }

    # Essai gratuit uniquement pour Essentiel
    if config[:trial_days] > 0
      session_params[:subscription_data] = {
        trial_period_days: config[:trial_days],
        metadata: { user_id: current_user.id, plan: plan }
      }
    end

    checkout_session = Stripe::Checkout::Session.create(session_params)
    redirect_to checkout_session.url, allow_other_host: true
  end

  # GET /subscriptions/success
  def success
    # Le webhook Stripe va créer/mettre à jour la subscription
    # On redirige vers le dashboard avec un message
    redirect_to dashboard_path,
      notice: "🎉 Abonnement activé ! Bienvenue sur l'offre #{params[:plan]&.capitalize}."
  end

  # DELETE /subscriptions/cancel
  def cancel
    sub = current_user.subscription
    return redirect_to subscriptions_path, alert: "Aucun abonnement actif." unless sub&.active?

    Stripe::Subscription.update(
      sub.stripe_subscription_id,
      { cancel_at_period_end: true }
    )

    sub.update!(cancelled_at: Time.current)
    redirect_to subscriptions_path,
      notice: "Abonnement résilié. Votre accès reste actif jusqu'au #{I18n.l(sub.current_period_ends_at, format: :long)}."
  end

  # GET /subscriptions/portal — portail client Stripe
  def portal
    sub = current_user.subscription
    return redirect_to subscriptions_path unless sub&.stripe_customer_id

    session = Stripe::BillingPortal::Session.create({
      customer:   sub.stripe_customer_id,
      return_url: subscriptions_url
    })
    redirect_to session.url, allow_other_host: true
  end

  private

  def find_or_create_stripe_customer
    if current_user.subscription&.stripe_customer_id
      Stripe::Customer.retrieve(current_user.subscription.stripe_customer_id)
    else
      Stripe::Customer.create({
        email: current_user.email,
        name:  "#{current_user.first_name} #{current_user.last_name}",
        metadata: { user_id: current_user.id }
      })
    end
  end
end
