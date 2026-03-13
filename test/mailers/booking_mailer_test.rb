require "test_helper"

class BookingMailerTest < ActionMailer::TestCase
  test "confirmation" do
    mail = BookingMailer.confirmation
    assert_equal "Confirmation", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "reminder" do
    mail = BookingMailer.reminder
    assert_equal "Reminder", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "cancellation" do
    mail = BookingMailer.cancellation
    assert_equal "Cancellation", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
