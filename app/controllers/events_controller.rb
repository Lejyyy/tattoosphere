class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  def index
    @events = policy_scope(Event).where(is_public: true).order(:start_date)
  end

  def show
    authorize @event
  end

  def new
    @event = Event.new
    authorize @event
  end

  def create
    @event = Event.new(event_params)
    authorize @event
    if @event.save
      redirect_to @event, notice: "Événement créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @event
  end

  def update
    authorize @event
    if @event.update(event_params)
      redirect_to @event, notice: "Événement mis à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event
    @event.destroy
    redirect_to events_path, notice: "Événement supprimé"
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
  params.require(:event).permit(
    :name, :description, :location,
    :start_date, :end_date, :is_public,
    :shop_id, :tatoueur_id, :banner
  )
end
end
