module NotificationsHelper
  ICONS = {
    "message"            => "💬",
    "booking_confirmed"  => "✅",
    "booking_cancelled"  => "❌",
    "new_event"          => "🎉"
  }.freeze

  def notification_icon(kind)
    ICONS[kind] || "🔔"
  end
end
