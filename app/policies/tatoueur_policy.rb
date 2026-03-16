class TatoueurPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def new?
    user.user? && user.tatoueur.nil?
  end

  def create?
    user.user? && user.tatoueur.nil?
  end

  def update?
    (user.tatoueur? && record.user == user) || user.admin?
  end

  def update_photos?
  update?
end

def delete_photo?
  update?
end

  def edit?    = update?
  def destroy? = update?

  def verification?        = update?
  def submit_verification? = update?
  def connect_paypal?      = update?
  def paypal_callback?     = update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(is_active: true)
    end
  end
end
