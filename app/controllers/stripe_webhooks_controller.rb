class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: []  # pas d'auth pour les webhooks

  def create
    payload    = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"]
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error("[Stripe Webhook] Erreur signature : #{e.message}")
      return head :bad_request
    end

    case event["type"]
    when "checkout.session.completed"
      handle_checkout_completed(event["data"]["object"])
    when "invoice.payment_succeeded"
      handle_payment_succeeded(event["data"]["object"])
    when "invoice.payment_failed"
      handle_payment_failed(event["data"]["object"])
    when "customer.subscription.deleted"
      handle_subscription_deleted(event["data"]["object"])
    when "customer.subscription.trial_will_end"
      handle_trial_will_end(event["data"]["object"])
    end

    head :ok
  end

  private

  def handle_checkout_completed(session)
    user_id = session.dig("metadata", "user_id")
    plan    = session.dig("metadata", "plan")
    return unless user_id && plan

    user   = User.find_by(id: user_id)
    config = Subscription::PLANS[plan]
    return unless user && config

    stripe_sub = Stripe::Subscription.retrieve(session["subscription"])

    sub = user.subscription || user.build_subscription
    sub.assign_attributes(
      plan:                    plan,
      status:                  stripe_sub.status == "trialing" ? "trialing" : "active",
      stripe_subscription_id:  stripe_sub.id,
      stripe_customer_id:      session["customer"],
      trial_ends_at:           stripe_sub.trial_end ? Time.at(stripe_sub.trial_end) : nil,
      current_period_ends_at:  Time.at(stripe_sub.current_period_end),
      events_reset_at:         Time.current,
      free_events_used:        0,
      featured_until:          config[:featured_days] > 0 ? config[:featured_days].days.from_now : nil
    )
    sub.save!

    # Mettre à jour le featured sur le profil
    update_featured(user, config)

    # Notifier l'user
    SubscriptionMailer.confirmation(user, plan).deliver_later
  end

  def handle_payment_succeeded(invoice)
    stripe_sub_id = invoice["subscription"]
    return unless stripe_sub_id

    sub = Subscription.find_by(stripe_subscription_id: stripe_sub_id)
    return unless sub

    stripe_sub = Stripe::Subscription.retrieve(stripe_sub_id)
    sub.update!(
      status:                 "active",
      current_period_ends_at: Time.at(stripe_sub.current_period_end)
    )

    # Renouvellement : reset events si nouvelle année
    sub.send(:reset_events_if_needed!)
  end

  def handle_payment_failed(invoice)
    stripe_sub_id = invoice["subscription"]
    return unless stripe_sub_id

    sub = Subscription.find_by(stripe_subscription_id: stripe_sub_id)
    return unless sub

    SubscriptionMailer.payment_failed(sub.user).deliver_later
  end

  def handle_subscription_deleted(stripe_sub)
    sub = Subscription.find_by(stripe_subscription_id: stripe_sub["id"])
    return unless sub

    sub.update!(status: "expired", current_period_ends_at: Time.current)

    # Retirer le featured et remettre le rôle user
    user = sub.user
    update_featured(user, { featured_days: 0 })
    user.tatoueur&.update(featured: false)
    user.shop&.update(featured: false)

    SubscriptionMailer.expired(user).deliver_later
  end

  def handle_trial_will_end(stripe_sub)
    sub = Subscription.find_by(stripe_subscription_id: stripe_sub["id"])
    return unless sub

    # Envoie le rappel J-1
    SubscriptionMailer.trial_ending(sub.user).deliver_later
  end

  def update_featured(user, config)
    featured = config[:featured_days] > 0
    user.tatoueur&.update(featured: featured)
    user.shop&.update(featured: featured)
  end
end
