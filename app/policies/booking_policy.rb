class BookingPolicy < ApplicationPolicy
  def index?   = true
  def new?     = create?
  def show?    = record.user == user || tatoueur_owner? || shop_owner? || user.admin?
  def create? = user.user? || user.tatoueur? || user.admin?
  def update?  = tatoueur_owner? || shop_owner? || user.admin?
  def destroy? = record.user == user || tatoueur_owner? || shop_owner? || user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.tatoueur?
        scope.where(user: user).or(scope.where(tatoueur: user.tatoueur))
      elsif user.shop_owner?
        scope.where(shop: user.shop)
      else
        scope.where(user: user)
      end
    end
  end

  private

  def tatoueur_owner?
    user.tatoueur? && user.tatoueur == record.tatoueur
  end

  def shop_owner?
    user.shop_owner? && user.shop == record.shop
  end
end
