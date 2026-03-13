# Preview all emails at http://localhost:3000/rails/mailers/booking_mailer
class BookingMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/confirmation
  def confirmation
    BookingMailer.confirmation
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/reminder
  def reminder
    BookingMailer.reminder
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/cancellation
  def cancellation
    BookingMailer.cancellation
  end
end
