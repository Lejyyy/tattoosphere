class Admin::VerificationsController < Admin::BaseController
  before_action :set_tatoueur, only: [ :show, :approve, :reject ]

  # GET /admin/verifications
  def index
    @pending   = Tatoueur.where(verification_status: "pending").order(verification_submitted_at: :asc)
    @rejected  = Tatoueur.where(verification_status: "rejected").order(verification_reviewed_at: :desc)
    @approved  = Tatoueur.where(verification_status: "approved").order(verification_reviewed_at: :desc)
  end

  # GET /admin/verifications/:id
  def show
  end

  # PATCH /admin/verifications/:id/approve
  def approve
    @tatoueur.approve_verification!
    TatoueurMailer.verification_approved(@tatoueur).deliver_later
    redirect_to admin_verifications_path, notice: "#{@tatoueur.nickname} a été vérifié."
  end

  # PATCH /admin/verifications/:id/reject
  def reject
    reason = params[:reason].presence || "Aucune raison précisée."
    @tatoueur.reject_verification!(reason)
    TatoueurMailer.verification_rejected(@tatoueur, reason).deliver_later
    redirect_to admin_verifications_path, notice: "Demande de #{@tatoueur.nickname} rejetée."
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:id])
  end
end
