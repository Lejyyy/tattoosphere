
class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: [ :show, :edit, :update, :destroy, :feature, :unfeature ]

  def index
    @events = Event.includes(:tatoueur, :shop).order(start_date: :desc)
    @events = @events.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @events = @events.where(featured: true) if params[:filter] == "featured"
    @events = @events.page(params[:page]).per(30)
  end

  def show; end
  def edit; end

  def update
    if @event.update(event_params)
      log_action("update_event", @event)
      redirect_to admin_event_path(@event), notice: "Événement mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    log_action("delete_event", @event)
    redirect_to admin_events_path, notice: "Événement supprimé."
  end

  def feature
    @event.update(featured: true)
    log_action("feature_event", @event)
    redirect_back fallback_location: admin_events_path, notice: "Événement mis en avant ⭐"
  end

  def unfeature
    @event.update(featured: false)
    redirect_back fallback_location: admin_events_path, notice: "Retiré."
  end

  private
  def set_event = @event = Event.find(params[:id])
  def event_params = params.require(:event).permit(:name, :description, :location,
                                                    :start_date, :end_date, :is_public)
end
