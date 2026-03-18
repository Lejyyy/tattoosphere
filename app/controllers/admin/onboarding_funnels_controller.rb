class Admin::OnboardingFunnelsController < Admin::BaseController
  def index
    @funnels = OnboardingFunnel.includes(:user)
                               .order(created_at: :desc)

    # Filtres
    @funnels = @funnels.where(kind: params[:kind])   if params[:kind].present?
    @funnels = @funnels.where(step: params[:step])   if params[:step].present?
    @funnels = @funnels.where(subscribed_at: nil)    if params[:not_subscribed] == "1"

    # Stats
    @stats = {
      total:            OnboardingFunnel.count,
      form_completed:   OnboardingFunnel.where.not(form_completed_at: nil).count,
      page_visited:     OnboardingFunnel.where.not(subscription_page_visited_at: nil).count,
      plan_selected:    OnboardingFunnel.where.not(plan_selected_at: nil).count,
      subscribed:       OnboardingFunnel.where.not(subscribed_at: nil).count,
      by_plan:          OnboardingFunnel.where.not(plan_selected: nil)
                                        .group(:plan_selected).count
    }
  end

  def send_reminder
    funnel = OnboardingFunnel.find(params[:id])
    return redirect_to admin_onboarding_funnels_path, alert: "Déjà abonné." if funnel.subscribed_at.present?

    # Envoie le prochain reminder non encore envoyé
    next_reminder = if funnel.reminder_1_sent_at.nil? then 1
    elsif funnel.reminder_2_sent_at.nil? then 2
    elsif funnel.reminder_3_sent_at.nil? then 3
    end

    if next_reminder
      OnboardingMailer.reminder(funnel, next_reminder).deliver_later
      col = "reminder_#{next_reminder}_sent_at"
      funnel.update!(col => Time.current)
      redirect_to admin_onboarding_funnels_path, notice: "Relance ##{next_reminder} envoyée à #{funnel.user.email}."
    else
      redirect_to admin_onboarding_funnels_path, alert: "Toutes les relances ont déjà été envoyées."
    end
  end
end
