class PortfolioPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true
  def new?    = create?

  def create?
    user.tatoueur? && record.tatoueur.user == user
  end

  def update?
    create? || user.admin?
  end

  def destroy?
    create? || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
