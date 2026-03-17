class NotificationService
  # Appel générique
  def self.notify(user:, kind:, title:, body: nil, url: nil, notifiable: nil)
    notif = user.notifications.create!(
      kind:        kind,
      title:       title,
      body:        body,
      url:         url,
      notifiable:  notifiable
    )
    broadcast(notif)
    notif
  end

  # --- Nouveau message ---
  def self.new_message(message)
    conversation = message.conversation
    recipients = conversation.participants
                             .reject { |p| p == message.sender }

    recipients.each do |recipient|
      user = recipient.is_a?(User) ? recipient : recipient.user
      notify(
        user:       user,
        kind:       "message",
        title:      "Nouveau message",
        body:       "#{message.sender_name} vous a envoyé un message",
        url:        "/conversations/#{conversation.id}",
        notifiable: message
      )
    end
  end

  # --- Réservation confirmée ---
  def self.booking_confirmed(booking)
    notify(
      user:       booking.client,
      kind:       "booking_confirmed",
      title:      "Réservation confirmée ✓",
      body:       "Votre réservation du #{I18n.l(booking.date, format: :long)} a été confirmée",
      url:        "/bookings/#{booking.id}",
      notifiable: booking
    )
  end

  # --- Réservation annulée ---
  def self.booking_cancelled(booking, cancelled_by:)
    # Notifier le client
    notify(
      user:       booking.client,
      kind:       "booking_cancelled",
      title:      "Réservation annulée",
      body:       "Votre réservation du #{I18n.l(booking.date, format: :long)} a été annulée",
      url:        "/bookings/#{booking.id}",
      notifiable: booking
    )

    # Notifier le tatoueur si c'est le client qui annule
    if cancelled_by == booking.client
      notify(
        user:       booking.tatoueur.user,
        kind:       "booking_cancelled",
        title:      "Réservation annulée par le client",
        body:       "#{booking.client.full_name} a annulé sa réservation du #{I18n.l(booking.date, format: :long)}",
        url:        "/tatoueurs/#{booking.tatoueur.id}/bookings",
        notifiable: booking
      )
    end
  end

  # --- Nouvel événement d'un tatoueur suivi ---
  def self.new_event(event)
    tatoueur = event.tatoueur
    followers = tatoueur.followers # => collection de Users

    followers.each do |follower|
      notify(
        user:       follower,
        kind:       "new_event",
        title:      "Nouvel événement",
        body:       "#{tatoueur.nom} participe à « #{event.title} »",
        url:        "/events/#{event.id}",
        notifiable: event
      )
    end
  end

  private

  def self.broadcast(notification)
    ActionCable.server.broadcast(
      "notifications_#{notification.user_id}",
      {
        id:         notification.id,
        kind:       notification.kind,
        title:      notification.title,
        body:       notification.body,
        url:        notification.url,
        created_at: notification.created_at.strftime("%H:%M")
      }
    )
  end
end
