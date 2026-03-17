class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  belongs_to :tatoueur
  has_one :review

  STATUSES       = %w[pending confirmed done cancelled].freeze
  PAYMENT_METHODS = %w[bank_transfer paypal].freeze

  validates :date, :status, presence: true
  validates :status,         inclusion: { in: STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_nil: true
  validates :date, comparison: { greater_than: Time.current }, on: :create

  after_create  :send_confirmation_email
  after_update  :send_cancellation_email, if: :just_cancelled?
  after_update  :send_deposit_confirmed_email, if: :just_confirmed_deposit?

  has_one :payment

  after_initialize :set_default_status

  def deposit_paid?
    deposit_paid == true
  end

  def just_cancelled?
    saved_change_to_status? && status == "cancelled"
  end

  def just_confirmed_deposit?
    saved_change_to_deposit_paid? && deposit_paid?
  end

  def cancellable?
    %w[pending confirmed].include?(status)
  end

  def deposit_amount
    tatoueur&.deposit_amount || 50.0
  end

  after_update_commit :notify_status_change, if: :saved_change_to_status?

  private

  def send_confirmation_email
    BookingMailer.confirmation(self).deliver_later
  end

  def send_cancellation_email
    BookingMailer.cancellation(self).deliver_later
  end

  def send_deposit_confirmed_email
    BookingMailer.deposit_confirmed(self).deliver_later
  end

  def set_default_status
  self.status ||= "pending"
end

def notify_status_change
    case status
    when "confirmed"
      NotificationService.booking_confirmed(self)
    when "cancelled"
      NotificationService.booking_cancelled(self, cancelled_by: cancelled_by_user)
    end

  def cancelled_by_user
    client
  end
end
end
