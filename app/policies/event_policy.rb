class EventPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def new?     = create?
  def create?  = user.tatoueur? || user.shop_owner? || user.admin?
  def update?  = owner? || user.admin?
  def edit?    = update?
  def destroy? = owner? || user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(is_public: true)
    end
  end

  private

  def owner?
    (record.tatoueur && record.tatoueur.user == user) ||
    (record.shop && record.shop.user == user)
  end
end
