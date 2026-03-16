class TatoueurPanel::PortfolioController < TatoueurPanel::BaseController
  def index
    @portfolios = current_tatoueur.portfolios.includes(:portfolio_items)
  end
end
