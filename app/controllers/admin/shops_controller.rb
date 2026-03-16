
class Admin::ShopsController < Admin::BaseController
  before_action :set_shop, only: [ :show, :ban, :unban, :feature, :unfeature ]

  def index
    @shops = Shop.includes(:user, cover_attachment: :blob).order(created_at: :desc)
    @shops = @shops.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @shops = @shops.where(featured: true) if params[:filter] == "featured"
    @shops = @shops.where(banned: true)   if params[:filter] == "banned"
    @shops = @shops.page(params[:page]).per(30)
  end

  def show
    @reports = Report.where(reportable: @shop)
    @logs    = AdminLog.where(target_type: "Shop", target_id: @shop.id).recent
  end

  def ban
    @shop.update(banned: true, is_active: false)
    log_action("ban_shop", @shop, params[:note])
    redirect_to admin_shop_path(@shop), notice: "Shop banni."
  end

  def unban
    @shop.update(banned: false, is_active: true)
    log_action("unban_shop", @shop)
    redirect_to admin_shop_path(@shop), notice: "Bannissement levé."
  end

  def feature
    @shop.update(featured: true)
    log_action("feature_shop", @shop)
    redirect_back fallback_location: admin_shops_path, notice: "Shop mis en avant ⭐"
  end

  def unfeature
    @shop.update(featured: false)
    redirect_back fallback_location: admin_shops_path, notice: "Retiré de la mise en avant."
  end

  private
  def set_shop = @shop = Shop.find(params[:id])
end
