class TatoueurPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def create?
    user.tatoueur?
  end

  def update?
    user.tatoueur? && record.user == user
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(is_active: true)
    end
  end
end
