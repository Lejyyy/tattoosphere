class Subscription < ApplicationRecord
  belongs_to :user

  PLANS = {
    "essentiel" => {
      price_id:     "price_1TCFtPIuFr19Juts1wBLf1da",
      amount:       15_00,
      trial_days:   7,
      free_events:  0,
      featured_days: 0,
      verified:     false
    },
    "pro" => {
      price_id:     "price_1TCFtbIuFr19JutsdYQOFpg6",
      amount:       20_00,
      trial_days:   0,
      free_events:  1,
      featured_days: 14,
      verified:     false
    },
    "master" => {
      price_id:     "price_1TCFtqIuFr19JutsuxpZK57r",
      amount:       39_00,
      trial_days:   0,
      free_events:  5,
      featured_days: 365,
      verified:     true   # admin doit valider
    }
  }.freeze

  STATUSES = %w[trialing active cancelled expired].freeze

  validates :plan,   inclusion: { in: PLANS.keys }
  validates :status, inclusion: { in: STATUSES }

  scope :active,   -> { where(status: %w[active trialing]) }
  scope :expired,  -> { where(status: %w[cancelled expired]) }

  def active?
    status.in?(%w[active trialing]) &&
      (current_period_ends_at.nil? || current_period_ends_at.future?)
  end

  def trialing?
    status == "trialing" && trial_ends_at&.future?
  end

  def plan_config
    PLANS[plan]
  end

  def free_events_remaining
    return 0 if plan_config[:free_events].zero?
    reset_events_if_needed!
    plan_config[:free_events] - free_events_used
  end

  def use_free_event!
    reset_events_if_needed!
    increment!(:free_events_used)
  end

  def featured?
    featured_until&.future?
  end

  private

  def reset_events_if_needed!
    return unless events_reset_at
    if Time.current >= events_reset_at + 1.year
      update_columns(
        free_events_used: 0,
        events_reset_at:  events_reset_at + 1.year
      )
    end
  end
end
