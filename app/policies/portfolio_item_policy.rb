class PortfolioItemPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true
  def new?    = create?

  def create?
    user.tatoueur? && record.portfolio.tatoueur.user == user
  end

  def update?  = create? || user.admin?
  def destroy? = create? || user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
