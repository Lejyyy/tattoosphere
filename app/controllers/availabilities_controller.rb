class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tatoueur

  def index
    authorize @tatoueur, :update?
    @availabilities = @tatoueur.availabilities.order(:day_of_week, :start_time)
    @availability   = Availability.new

    # Bookings confirmés des 8 prochaines semaines
    @confirmed_bookings = @tatoueur.bookings
                                   .where(status: "confirmed")
                                   .where(date: Date.today..8.weeks.from_now)
                                   .select(:date, :start_time)

    # Blocked slots des 8 prochaines semaines
    @blocked_slots = @tatoueur.blocked_slots
                              .where(date: Date.today..8.weeks.from_now)
                              .order(:date, :start_time)
  end

  def create
    authorize @tatoueur, :update?
    data    = JSON.parse(params[:availabilities_data] || "{}")
    day_map = { "lun" => 1, "mar" => 2, "mer" => 3, "jeu" => 4,
                "ven" => 5, "sam" => 6, "dim" => 0 }

    @tatoueur.availabilities.destroy_all

    data.each do |day_key, slots|
      day_num = day_map[day_key]
      next unless day_num
      slots.sort.each do |slot|
        h, m   = slot.split(":").map(&:to_i)
        start  = Time.new(2000, 1, 1, h, m)
        finish = start + 30.minutes
        @tatoueur.availabilities.create!(
          day_of_week: day_num,
          start_time:  start,
          end_time:    finish
        )
      end
    end

    redirect_to tatoueur_availabilities_path(@tatoueur), notice: "Disponibilités enregistrées."
  end

  def destroy
    authorize @tatoueur, :update?
    @tatoueur.availabilities.find(params[:id]).destroy
    redirect_to tatoueur_availabilities_path(@tatoueur), notice: "Disponibilité supprimée."
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
  end
end
