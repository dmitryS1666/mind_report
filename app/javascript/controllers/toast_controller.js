import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { type: String, timeout: Number }

  connect() {
    const t = this.timeoutValue || 6000
    this.autoTimer = setTimeout(() => this.dismiss(), t)
  }

  disconnect() {
    clearTimeout(this.autoTimer)
  }

  dismiss() {
    this.element.classList.add("transition-opacity", "duration-200", "opacity-0", "pointer-events-none")
    setTimeout(() => this.element.remove(), 220)
  }
}
