class BookingPolicy < ApplicationPolicy
  def index?  = true
  def show?   = record.user == user || tatoueur_owns_booking? || user.admin?
  def new?    = create?

  def create?
    user.user?
  end

  def update?
    record.user == user || tatoueur_owns_booking? || user.admin?
  end

  def destroy?
    (record.user == user && record.cancellable?) || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.tatoueur?
        scope.where(user: user).or(scope.where(tatoueur: user.tatoueur))
      else
        scope.where(user: user)
      end
    end
  end

  private

  def tatoueur_owns_booking?
    user.tatoueur? && user.tatoueur == record.tatoueur
  end
end
