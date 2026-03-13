import consumer from "./consumer"

let subscription = null

// Initialise le canal pour une conversation donnée
const initConversationChannel = (conversationId) => {
  // Évite les souscriptions multiples
  if (subscription) {
    subscription.unsubscribe()
  }

  subscription = consumer.subscriptions.create(
    {
      channel: "ConversationChannel",
      conversation_id: conversationId
    },
    {
      connected() {
        console.log(`[ConversationChannel] Connecté à la conversation ${conversationId}`)
      },

      disconnected() {
        console.log("[ConversationChannel] Déconnecté")
      },

      received(data) {
        const messagesContainer = document.getElementById("messages")
        if (!messagesContainer) return

        // Insérer le nouveau message
        messagesContainer.insertAdjacentHTML("beforeend", buildMessageHTML(data))

        // Scroll automatique vers le bas
        scrollToBottom()

        // Marquer comme lu si la fenêtre est active
        if (document.visibilityState === "visible") {
          markAsRead(conversationId)
        }
      }
    }
  )
}

// Construit le HTML d'un nouveau message reçu
const buildMessageHTML = (data) => {
  const isOwn = data.sender === document.getElementById("messages").dataset.currentUserNickname

  return `
    <div class="message ${isOwn ? "message--own" : "message--other"}" id="message-${data.message_id}">
      <div class="message__bubble">
        <p class="message__content mb-0">${escapeHTML(data.message)}</p>
      </div>
      <span class="message__meta text-secondary">${data.sender} · ${data.created_at}</span>
    </div>
  `
}

// Scroll vers le dernier message
const scrollToBottom = () => {
  const container = document.getElementById("messages")
  if (container) {
    container.scrollTop = container.scrollHeight
  }
}

// Marquer les messages comme lus via fetch
const markAsRead = (conversationId) => {
  fetch(`/conversations/${conversationId}/mark_read`, {
    method: "PATCH",
    headers: {
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      "Content-Type": "application/json"
    }
  })
}

// Échappe le HTML pour éviter les injections XSS
const escapeHTML = (str) => {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;")
}

// Auto-init si on est sur une page de conversation
document.addEventListener("turbo:load", () => {
  const messagesContainer = document.getElementById("messages")
  if (messagesContainer) {
    const conversationId = messagesContainer.dataset.conversationId
    if (conversationId) {
      initConversationChannel(conversationId)
      scrollToBottom()
    }
  }
})

export { initConversationChannel }