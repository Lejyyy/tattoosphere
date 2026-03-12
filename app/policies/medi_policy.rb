class MediaPolicy < ApplicationPolicy
  def index?  = true

  def create?
    owner_of_record?
  end

  def destroy?
    owner_of_record?
  end

  private

  def owner_of_record?
    (user.tatoueur? && record.tatoueur&.user == user) ||
    (user.shop_owner? && record.shop&.user == user)
  end
end
