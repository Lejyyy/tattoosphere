module BookingsHelper
  def booking_status_badge(status)
    case status
    when "pending"    then "bg-warning text-dark"
    when "confirmed"  then "bg-success"
    when "done"       then "bg-secondary"
    when "cancelled"  then "bg-danger"
    else                   "bg-secondary"
    end
  end
end
