class BookingReminderJob < ApplicationJob
  queue_as :default

  def perform
    Booking.where(date: Date.tomorrow, status: "confirmed")
           .each { |b| BookingMailer.reminder(b).deliver_later }
  end
end
