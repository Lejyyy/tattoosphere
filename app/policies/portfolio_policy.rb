class PortfolioPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def create?
    user.tatoueur? && record.tatoueur.user == user
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
