class BookingPolicy < ApplicationPolicy
  def index?  = true
  def show?   = record.user == user || tatoueur_owns_booking?

  def create?
    user.user?
  end

  def update?
    # Le tatoueur peut changer le statut, le client peut modifier sa réservation
    record.user == user || tatoueur_owns_booking?
  end

  def destroy?
    record.user == user
  end

  private

  def tatoueur_owns_booking?
    user.tatoueur? && user.tatoueur == record.tatoueur
  end
end
