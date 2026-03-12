class AvailabilityPolicy < ApplicationPolicy
  def index?  = true

  def create?
    user.tatoueur? && record.tatoueur.user == user
  end

  def destroy?
    create?
  end
end
