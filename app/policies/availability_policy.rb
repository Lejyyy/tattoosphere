class AvailabilityPolicy < ApplicationPolicy
  def index?  = true

  def create?
    user.tatoueur? && record.tatoueur.user == user
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
