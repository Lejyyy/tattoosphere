class MediaPolicy < ApplicationPolicy
  def index?  = true
  def create? = owner_of_record? || user.admin?
  def update? = owner_of_record? || user.admin?
  def destroy? = owner_of_record? || user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def owner_of_record?
    (user.tatoueur? && record.tatoueur&.user == user) ||
    (user.shop_owner? && record.shop&.user == user)
  end
end
