class ReviewPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def create?
    # Seul le client ayant une réservation "done" sans avis peut poster
    user.user? &&
      record.booking.user == user &&
      record.booking.status == "done" &&
      record.booking.review.nil?
  end

  def update?  = false
  def destroy? = false
end
