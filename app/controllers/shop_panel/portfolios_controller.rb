class ShopPanel::PortfoliosController < ShopPanel::BaseController
  def index
    @portfolios = Portfolio.where(tatoueur: current_shop.tatoueurs)
                           .includes(:portfolio_items, tatoueur: :avatar_attachment)
  end
end
