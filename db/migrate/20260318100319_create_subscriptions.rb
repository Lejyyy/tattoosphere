# rails generate migration CreateSubscriptions
class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user,            null: false, foreign_key: true
      t.string     :plan,            null: false  # "essentiel", "pro", "master"
      t.string     :status,          null: false, default: "trialing"
      # "trialing", "active", "cancelled", "expired"

      t.string     :stripe_subscription_id
      t.string     :stripe_customer_id

      t.datetime   :trial_ends_at
      t.datetime   :current_period_ends_at
      t.datetime   :cancelled_at

      # Events gratuits
      t.integer    :free_events_used,  default: 0
      t.datetime   :events_reset_at    # date anniversaire pour remise à zéro

      # Boost
      t.datetime   :featured_until

      t.timestamps
    end

    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, [ :user_id, :status ]
  end
end
