class EventPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def create?
    user.tatoueur? || user.shop_owner?
  end

  def update?
    # Tatoueur propriétaire OU shop owner propriétaire
    (user.tatoueur? && record.tatoueur&.user == user) ||
    (user.shop_owner? && record.shop&.user == user)
  end

  def destroy?
    update?
  end
end
