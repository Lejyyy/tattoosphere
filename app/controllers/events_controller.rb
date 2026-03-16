class EventsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  # GET /events
  # GET /shops/:shop_id/events
  # GET /tatoueurs/:tatoueur_id/events
  def index
  @events = Event.where(is_public: true).includes(:tatoueur, :shop).order(start_date: :asc)

  if params[:location].present?
    @events = @events.where("location ILIKE ?", "%#{params[:location]}%")
  end

  if params[:from].present?
    @events = @events.where("start_date >= ?", params[:from])
  end

  if params[:to].present?
    @events = @events.where("start_date <= ?", params[:to].to_date.end_of_day)
  end

  # Uniquement les événements à venir par défaut
  @events = @events.where("start_date >= ?", Time.current) unless params[:from].present?
end

  # GET /events/:id
  def show
    authorize @event
  end

  # GET /events/new
  def new
    @event = Event.new
    authorize @event
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    authorize @event
    if @event.save
      redirect_to @event, notice: "Événement créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /events/:id/edit
  def edit
    authorize @event
  end

  # PATCH /events/:id
  def update
    authorize @event
    if @event.update(event_params)
      redirect_to @event, notice: "Événement mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /events/:id
  def destroy
    authorize @event
    @event.destroy
    redirect_to events_path, notice: "Événement supprimé."
  end

  def participate
  @event = Event.find(params[:id])
  unless @event.participants.include?(current_user)
    @event.event_participations.create!(user: current_user)
  end
  redirect_to @event, notice: "Tu participes à cet événement ! 🎉"
  end

  def withdraw
    @event = Event.find(params[:id])
    participation = @event.event_participations.find_by(user: current_user)
    participation&.destroy
    redirect_to @event, notice: "Tu ne participes plus à cet événement."
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
