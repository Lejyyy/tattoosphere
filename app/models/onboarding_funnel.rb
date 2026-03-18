class OnboardingFunnel < ApplicationRecord
  belongs_to :user

  KINDS = %w[tatoueur shop].freeze
  STEPS = %w[clicked form_completed subscription_page_visited plan_selected subscribed].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :step, inclusion: { in: STEPS }

  scope :incomplete,      -> { where(subscribed_at: nil) }
  scope :form_completed,  -> { where.not(form_completed_at: nil) }
  scope :not_subscribed,  -> { form_completed.where(subscribed_at: nil) }

  STEP_ORDER = STEPS.each_with_index.to_h.freeze

  def advance_to!(new_step)
    return if STEP_ORDER[new_step] <= STEP_ORDER[step]
    attrs = { step: new_step }
    case new_step
    when "form_completed"         then attrs[:form_completed_at]            = Time.current
    when "subscription_page_visited" then attrs[:subscription_page_visited_at] = Time.current
    when "plan_selected"          then attrs[:plan_selected_at]             = Time.current
    when "subscribed"             then attrs[:subscribed_at]                = Time.current
    end
    update!(attrs)
  end

  def needs_reminder_1?
    form_completed_at.present? &&
      subscribed_at.nil? &&
      reminder_1_sent_at.nil? &&
      form_completed_at <= 1.hour.ago
  end

  def needs_reminder_2?
    form_completed_at.present? &&
      subscribed_at.nil? &&
      reminder_2_sent_at.nil? &&
      form_completed_at <= 24.hours.ago
  end

  def needs_reminder_3?
    form_completed_at.present? &&
      subscribed_at.nil? &&
      reminder_3_sent_at.nil? &&
      form_completed_at <= 5.days.ago
  end

  def step_label
    {
      "clicked"                    => "A cliqué",
      "form_completed"             => "Formulaire complété",
      "subscription_page_visited"  => "Page abonnement visitée",
      "plan_selected"              => "Plan sélectionné",
      "subscribed"                 => "Abonné ✓"
    }[step]
  end
end
