class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [ :new, :create ]
  before_action :set_review,  only: [ :reply ]

  # GET /bookings/:booking_id/reviews/new
  def new
    if @booking.review.present?
      redirect_to tatoueur_path(@booking.tatoueur), alert: "Vous avez déjà laissé un avis pour cette réservation."
      return
    end
    @review = Review.new
  end

  # POST /bookings/:booking_id/reviews
  def create
    @review = Review.new(review_params)
    @review.booking  = @booking
    @review.user     = current_user
    @review.tatoueur = @booking.tatoueur

    if @review.save
      redirect_to tatoueur_path(@booking.tatoueur), notice: "Votre avis a bien été publié. Merci !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /reviews/:id/reply
  def reply
    authorize @review, :reply?
    if @review.update(reply: params[:review][:reply], replied_at: Time.current)
      redirect_to tatoueur_path(@review.tatoueur), notice: "Votre réponse a été publiée."
    else
      redirect_to tatoueur_path(@review.tatoueur), alert: "La réponse ne peut pas être vide."
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:booking_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Réservation introuvable."
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
