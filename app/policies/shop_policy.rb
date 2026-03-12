class ShopPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def create?
    user.shop_owner?
  end

  def update?
    user.shop_owner? && record.user == user
  end

  def destroy?
    update?
  end

  # Associer/dissocier un tatoueur
  def add_tatoueur?
    update?
  end

  def remove_tatoueur?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(is_active: true)
    end
  end
end
