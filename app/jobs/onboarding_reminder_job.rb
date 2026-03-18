class OnboardingReminderJob < ApplicationJob
  queue_as :default

  def perform(funnel_id, reminder_number)
    funnel = OnboardingFunnel.find_by(id: funnel_id)
    return unless funnel
    return if funnel.subscribed_at.present?  # déjà souscrit, on n'envoie pas

    case reminder_number
    when 1
      return unless funnel.needs_reminder_1?
      OnboardingMailer.reminder(funnel, 1).deliver_now
      funnel.update!(reminder_1_sent_at: Time.current)
    when 2
      return unless funnel.needs_reminder_2?
      OnboardingMailer.reminder(funnel, 2).deliver_now
      funnel.update!(reminder_2_sent_at: Time.current)
    when 3
      return unless funnel.needs_reminder_3?
      OnboardingMailer.reminder(funnel, 3).deliver_now
      funnel.update!(reminder_3_sent_at: Time.current)
    end
  end
end
