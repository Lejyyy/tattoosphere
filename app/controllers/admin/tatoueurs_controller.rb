
class Admin::TatoueursController < Admin::BaseController
  before_action :set_tatoueur, only: [ :show, :update, :approve, :reject,
                                       :ban, :unban, :feature, :unfeature ]

  def index
    @tatoueurs = Tatoueur.includes(:user, avatar_attachment: :blob)
                         .order(created_at: :desc)
    @tatoueurs = @tatoueurs.where(verification_status: params[:status]) if params[:status].present?
    @tatoueurs = @tatoueurs.where(featured: true)  if params[:filter] == "featured"
    @tatoueurs = @tatoueurs.where(banned: true)    if params[:filter] == "banned"
    @tatoueurs = @tatoueurs.where("nickname ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @tatoueurs = @tatoueurs.page(params[:page]).per(30)
  end

  def show
    @reports = Report.where(reportable: @tatoueur)
    @logs    = AdminLog.where(target_type: "Tatoueur", target_id: @tatoueur.id).recent
  end

  def update
    case params[:action_type]
    when "approve"
      @tatoueur.approve_verification!
      TatoueurMailer.verification_approved(@tatoueur).deliver_later
      log_action("approve_tatoueur", @tatoueur)
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur vérifié ✅"
    when "reject"
      @tatoueur.reject_verification!(params[:reason])
      TatoueurMailer.verification_rejected(@tatoueur).deliver_later
      log_action("reject_tatoueur", @tatoueur, params[:reason])
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur refusé."
    when "activate"
      @tatoueur.update(is_active: true)
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur activé."
    when "deactivate"
      @tatoueur.update(is_active: false)
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur désactivé."
    end
  end

  def approve
    @tatoueur.approve_verification!
    TatoueurMailer.verification_approved(@tatoueur).deliver_later
    log_action("approve_tatoueur", @tatoueur)
    redirect_back fallback_location: admin_tatoueurs_path, notice: "Vérifié ✅"
  end

  def reject
    @tatoueur.reject_verification!(params[:reason])
    log_action("reject_tatoueur", @tatoueur, params[:reason])
    redirect_back fallback_location: admin_tatoueurs_path, notice: "Refusé."
  end

  def ban
    @tatoueur.update(banned: true, is_active: false)
    log_action("ban_tatoueur", @tatoueur, params[:note])
    redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur banni."
  end

  def unban
    @tatoueur.update(banned: false, is_active: true)
    log_action("unban_tatoueur", @tatoueur)
    redirect_to admin_tatoueur_path(@tatoueur), notice: "Bannissement levé."
  end

  def feature
    @tatoueur.update(featured: true)
    log_action("feature_tatoueur", @tatoueur)
    redirect_back fallback_location: admin_tatoueurs_path, notice: "Mis en avant ⭐"
  end

  def unfeature
    @tatoueur.update(featured: false)
    log_action("unfeature_tatoueur", @tatoueur)
    redirect_back fallback_location: admin_tatoueurs_path, notice: "Retiré de la mise en avant."
  end

  private
  def set_tatoueur = @tatoueur = Tatoueur.find(params[:id])
end
