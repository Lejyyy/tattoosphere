class ShopPanel::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_shop!
  layout "shop_panel"

  private

  def require_shop!
    unless current_user.shop.present?
      redirect_to root_path, alert: "Accès réservé aux shops."
    end
  end

  def current_shop
    @current_shop ||= current_user.shop
  end
  helper_method :current_shop
end
