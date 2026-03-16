
class Admin::ReportsController < Admin::BaseController
  before_action :set_report, only: [ :show, :update ]

  def index
    @reports = Report.includes(:reporter, :reportable)
                     .order(created_at: :desc)
    @reports = @reports.where(status: params[:status].presence || "pending")
    @reports = @reports.page(params[:page]).per(30)
  end

  def show; end

  def update
    case params[:resolution]
    when "resolve"
      @report.update(status: "resolved", resolved_by: current_user.id,
                     admin_note: params[:admin_note])
      log_action("resolve_report", @report.reportable)
      redirect_to admin_reports_path, notice: "Signalement résolu."
    when "dismiss"
      @report.update(status: "dismissed", resolved_by: current_user.id,
                     admin_note: params[:admin_note])
      redirect_to admin_reports_path, notice: "Signalement ignoré."
    end
  end

  private
  def set_report = @report = Report.find(params[:id])
end
