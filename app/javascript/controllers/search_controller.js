import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  // Debounce — attend 400ms après la dernière frappe avant de soumettre
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.closest("form").requestSubmit()
    }, 400)
  }
}
