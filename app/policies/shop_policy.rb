class ShopPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true

  def new?
    user.shop_owner? && user.shop.nil?
  end

  def create?
    user.shop_owner? && user.shop.nil?
  end

  def update?  = record.user == user || user.admin?
  def edit?    = update?
  def destroy? = update?

  def add_tatoueur?    = update?
  def remove_tatoueur? = update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(is_active: true)
    end
  end
end
