class TatoueurPanel::EventsController < TatoueurPanel::BaseController
  def index
    @events = current_tatoueur.events.order(start_date: :desc)
  end
end
