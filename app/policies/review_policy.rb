class ReviewPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def new?
    create?
  end

  def create?
    user.user? &&
      record.booking.user == user &&
      record.booking.status == "done" &&
      record.booking.review.nil?
  end

  def update?  = false
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
