import { Controller } from "@hotwired/stimulus"

// data-controller="typewriter"
// Optional: data-typewriter-speed-value (ms per char, default 12)
export default class extends Controller {
  static values = { speed: { type: Number, default: 12 } }

  connect() {
    const media = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)')
    if (media && media.matches) return

    this.full = this.element.textContent || ""
    this.element.textContent = ""
    this.i = 0
    this.timer = setInterval(() => {
      this.element.textContent += this.full[this.i++] || ""
      if (this.i >= this.full.length) this._stop()
      this.element.scrollTop = this.element.scrollHeight
    }, this.speedValue)
  }

  disconnect() { this._stop() }

  _stop() { if (this.timer) { clearInterval(this.timer); this.timer = null } }
}
