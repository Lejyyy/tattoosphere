class EventPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true
  def new?    = create?

  def create?
    user.tatoueur? || user.shop_owner?
  end

  def update?
    (user.tatoueur? && record.tatoueur&.user == user) ||
    (user.shop_owner? && record.shop&.user == user) ||
    user.admin?
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(is_public: true)
      end
    end
  end
end
