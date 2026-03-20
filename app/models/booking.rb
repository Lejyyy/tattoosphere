class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :shop,     optional: true
  belongs_to :tatoueur
  has_one    :review
  has_one    :payment
  has_one_attached :reference_image


  STATUSES        = %w[pending confirmed done cancelled].freeze
  PAYMENT_METHODS = %w[bank_transfer paypal].freeze

  # La date est optionnelle à la création (demande sans date)
  # mais requise à la mise à jour (le tatoueur doit fixer une date)
  validates :status, presence: true
  validates :date,   presence: true, on: :update
  validates :date,   comparison: { greater_than: Time.current }, on: :create, if: :date?

  validates :status,         inclusion: { in: STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_nil: true

  after_initialize  :set_default_status
  after_create      :send_confirmation_email
  after_update      :send_cancellation_email,      if: :just_cancelled?
  after_update      :send_deposit_confirmed_email,  if: :just_confirmed_deposit?
  after_update_commit :notify_status_change,        if: :saved_change_to_status?

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

  def date?
    date.present?
  end

  private

  def set_default_status
    self.status ||= "pending"
  end

  def send_confirmation_email
    BookingMailer.confirmation(self).deliver_later
  end

  def send_cancellation_email
    BookingMailer.cancellation(self).deliver_later
  end

  def send_deposit_confirmed_email
    BookingMailer.deposit_confirmed(self).deliver_later
  end

  def notify_status_change
    case status
    when "confirmed"
      NotificationService.booking_confirmed(self)
    when "cancelled"
      NotificationService.booking_cancelled(self, cancelled_by: current_user)
    end
  end
end
