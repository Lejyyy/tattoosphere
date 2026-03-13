class EventsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  # GET /events
  # GET /shops/:shop_id/events
  # GET /tatoueurs/:tatoueur_id/events
  def index
    @events = policy_scope(Event).order(:start_date)
    @events = @events.where(is_public: true) unless current_user&.admin?

    if params[:shop_id]
      @owner  = Shop.find(params[:shop_id])
      @events = @events.where(shop: @owner)
    elsif params[:tatoueur_id]
      @owner  = Tatoueur.find(params[:tatoueur_id])
      @events = @events.where(tatoueur: @owner)
    end

    @events = @events.where("start_date >= ?", Date.today) unless params[:past].present?
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
