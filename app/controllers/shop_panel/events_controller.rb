class ShopPanel::EventsController < ShopPanel::BaseController
  def index
    @events = current_shop.events.order(start_date: :desc)
  end
end
