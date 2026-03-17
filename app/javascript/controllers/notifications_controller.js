import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["badge", "dropdown", "list"]
  static values  = { count: Number }

  connect() {
    this.subscription = consumer.subscriptions.create("NotificationsChannel", {
      received: (data) => this.handleNotification(data)
    })
    this.updateBellState()

    // Ferme le dropdown en cliquant ailleurs
    this._outsideClick = (e) => {
      if (!this.element.contains(e.target)) this.closeDropdown()
    }
    document.addEventListener("click", this._outsideClick)
  }

  disconnect() {
    this.subscription?.unsubscribe()
    document.removeEventListener("click", this._outsideClick)
  }

  toggleDropdown() {
    if (!this.hasDropdownTarget) return
    const hidden = this.dropdownTarget.hidden
    this.dropdownTarget.hidden = !hidden
  }

  closeDropdown() {
    if (this.hasDropdownTarget) this.dropdownTarget.hidden = true
  }

  updateBellState() {
    const bell = this.element.querySelector(".notif-bell")
    if (!bell) return
    bell.classList.toggle("has-unread", this.countValue > 0)
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }

  handleNotification(data) {
    // Met à jour le compteur
    this.countValue++
    this.updateBadge()

    // Insère la notif en haut de la liste si le dropdown est ouvert
    if (this.hasListTarget) {
      this.listTarget.insertAdjacentHTML("afterbegin", this.notificationHTML(data))
    }

    // Toast discret
    this.showToast(data)
  }

  countValueChanged() {
    this.updateBadge()
    this.updateBellState()
  }

  updateBadge() {
    if (!this.hasBadgeTarget) return
    const count = this.countValue
    this.badgeTarget.textContent = count > 99 ? "99+" : count
    this.badgeTarget.hidden = count === 0
  }

  showToast(data) {
    const toast = document.createElement("div")
    toast.className = "notification-toast"
    toast.innerHTML = `<strong>${data.title}</strong><p>${data.body || ""}</p>`
    document.body.appendChild(toast)
    setTimeout(() => toast.remove(), 4000)
  }

  notificationHTML(data) {
    return `
      <a href="${data.url || '#'}" class="notification-item unread" data-turbo-action="advance">
        <span class="notification-kind ${data.kind}"></span>
        <div>
          <strong>${data.title}</strong>
          <p>${data.body || ""}</p>
          <time>${data.created_at}</time>
        </div>
      </a>
    `
  }
}