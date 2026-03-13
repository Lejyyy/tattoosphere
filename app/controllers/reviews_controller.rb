class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking

  # GET /tatoueurs/:tatoueur_id/reviews
  def index
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
    @reviews  = @tatoueur.reviews.includes(:user).order(created_at: :desc)
  end

  # GET /bookings/:booking_id/review/new
  def new
    redirect_to @booking, alert: "Vous avez déjà laissé un avis pour ce booking." and return if @booking.review.present?
    redirect_to @booking, alert: "Ce booking n'est pas encore terminé."            and return unless @booking.status == "done"
    @review = Review.new
  end

  # POST /bookings/:booking_id/review
  def create
    redirect_to @booking, alert: "Vous avez déjà laissé un avis pour ce booking." and return if @booking.review.present?
    redirect_to @booking, alert: "Ce booking n'est pas encore terminé."            and return unless @booking.status == "done"

    @review          = Review.new(review_params)
    @review.user     = current_user
    @review.booking  = @booking
    @review.tatoueur = @booking.tatoueur

    if @review.save
      redirect_to @booking, notice: "Avis publié."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:booking_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
