class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def new
    @contact_request = ContactRequest.new
    if user_signed_in?
      @contact_request.name  = current_user.nickname
      @contact_request.email = current_user.email
    end
  end

  def create
    @contact_request = ContactRequest.new(contact_params)

    if @contact_request.save
      ContactMailer.new_contact_request(@contact_request).deliver_later
      redirect_to new_contact_path, notice: "Votre message a bien été envoyé. Nous vous répondrons dans les plus brefs délais."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_request).permit(:name, :email, :subject, :message)
  end
end
