class Admin::ContactRequestsController < Admin::BaseController
  before_action :set_contact_request, only: [ :show, :mark_read, :mark_answered ]

  def index
    @contact_requests = ContactRequest.recent

    if params[:status].present?
      @contact_requests = @contact_requests.where(status: params[:status])
    end

    @pending_count  = ContactRequest.where(status: "pending").count
    @read_count     = ContactRequest.where(status: "read").count
    @answered_count = ContactRequest.where(status: "answered").count
  end

  def show
    @contact_request.update(status: "read") if @contact_request.pending?
  end

  def mark_read
    @contact_request.update(status: "read")
    redirect_to admin_contact_requests_path, notice: "Message marqué comme lu."
  end

  def mark_answered
    @contact_request.update(status: "answered")
    redirect_to admin_contact_requests_path, notice: "Message marqué comme répondu."
  end

  private

  def set_contact_request
    @contact_request = ContactRequest.find(params[:id])
  end
end
