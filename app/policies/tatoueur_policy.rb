class TatoueurPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def new?
    user.tatoueur? && user.tatoueur.nil?
  end

  def create?
    user.tatoueur? && user.tatoueur.nil?
  end

  def update?
    user.tatoueur? && record.user == user
  end

  def destroy?
    update? || user.admin?
  end

  def verification?
    user.tatoueur? && record.user == user
  end

  def submit_verification?
    verification?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(is_active: true)
    end
  end
end
