class ContactMailer < ApplicationMailer
  def new_contact_request(contact_request)
    @contact_request = contact_request

    mail(
      to:       ENV.fetch("CONTACT_EMAIL", "contact@tattoosphere.fr"),
      reply_to: @contact_request.email,
      subject:  "[Tattoosphere] #{@contact_request.subject} — #{@contact_request.name}"
    )
  end
end
