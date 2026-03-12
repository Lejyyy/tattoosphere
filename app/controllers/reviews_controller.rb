class ReviewsController < ApplicationController
  before_action :set_booking

  def index
    @reviews = @tatoueur.reviews
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    @review.user = current_user
    @review.booking = @booking
    @review.tatoueur = @booking.tatoueur
    if @review.save
      redirect_to @booking, notice: "Avis publié"
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
