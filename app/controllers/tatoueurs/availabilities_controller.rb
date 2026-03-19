
class Tatoueurs::AvailabilitiesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  before_action :authenticate_for_calendar!

  def index
    tatoueur  = Tatoueur.find(params[:tatoueur_id])
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today.beginning_of_week
    end_date   = start_date + 6.days

    # Créneaux récurrents par jour de semaine
    avails = tatoueur.availabilities.group_by(&:day_of_week)

    # Jours bloqués manuellement
    blocked = tatoueur.blocked_slots
                      .where(date: start_date..end_date)
                      .group_by { |b| b.date.to_s }

    # RDV confirmés
    booked_slots = tatoueur.bookings
                           .where(status: "confirmed")
                           .where(date: start_date..end_date)
                           .group_by { |b| b.date.to_s }

    days = (start_date..end_date).map do |date|
      day_avails  = avails[date.wday] || []
      day_blocked = blocked[date.to_s] || []
      day_booked  = booked_slots[date.to_s] || []

      # Matin = créneaux avant 12h00, Après-midi = créneaux à partir de 12h00
      morning_avail = day_avails.any? { |a| a.start_time.strftime("%H:%M") < "12:00" }
      afternoon_avail = day_avails.any? { |a| a.start_time.strftime("%H:%M") >= "12:00" }

      morning_blocked = day_blocked.any? { |b|
        b.start_time.strftime("%H:%M") < "12:00" ||
        (b.start_time.strftime("%H:%M") < "12:00" && b.end_time.strftime("%H:%M") > "08:00")
      }
      afternoon_blocked = day_blocked.any? { |b|
        b.start_time.strftime("%H:%M") >= "12:00" ||
        (b.end_time.strftime("%H:%M") > "12:00")
      }

      morning_booked = day_booked.any? { |b|
        b.start_time && b.start_time.strftime("%H:%M") < "12:00"
      }
      afternoon_booked = day_booked.any? { |b|
        b.start_time.nil? || b.start_time.strftime("%H:%M") >= "12:00"
      }

      {
        date:      date.to_s,
        label:     I18n.l(date, format: "%a %d %b"),
        past:      date < Date.today,
        morning:   {
          available: morning_avail && !morning_blocked && !morning_booked,
          blocked:   morning_blocked || morning_booked
        },
        afternoon: {
          available: afternoon_avail && !afternoon_blocked && !afternoon_booked,
          blocked:   afternoon_blocked || afternoon_booked
        }
      }
    end

    render json: { days: days, start_date: start_date.to_s, end_date: end_date.to_s }
  end

  private

def authenticate_for_calendar!
  unless user_signed_in?
    render json: { error: "non_authentifié", redirect: new_user_session_path }, status: :unauthorized
  end
end
end
