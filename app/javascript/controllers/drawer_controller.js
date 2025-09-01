// app/javascript/controllers/drawer_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  open() {
    this.panelTarget.classList.remove("-translate-x-full", "opacity-0")
    this.backdropTarget.classList.remove("hidden")
  }

  close() {
    this.panelTarget.classList.add("-translate-x-full", "opacity-0")
    this.backdropTarget.classList.add("hidden")
  }

  backdrop(e) {
    if (e.target === this.backdropTarget) this.close()
  }

  escape(e) {
    if (e.key === "Escape") this.close()
  }
}
