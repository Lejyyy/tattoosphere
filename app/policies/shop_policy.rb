class ShopPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def new?
    user.shop_owner? && user.shop.nil?
  end

  def create?
    user.shop_owner? && user.shop.nil?
  end

  def update?
    (user.shop_owner? && record.user == user) || user.admin?
  end

  def destroy?
    update?
  end

  def add_tatoueur?
    update?
  end

  def remove_tatoueur?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(is_active: true)
    end
  end
end
