class PortfolioItemPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def create?
    user.tatoueur? && record.portfolio.tatoueur.user == user
  end

  def update?  = create?
  def destroy? = create?
end
