import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "panel"]

  connect() {
    // для дебага: в консоли увидишь
    // console.log("[modal] connected", { hasBackdrop: this.hasBackdropTarget, hasPanel: this.hasPanelTarget })

    // слушаем глобальное событие открытия
    this._openHandler = () => this.open()
    window.addEventListener("open-history", this._openHandler)
  }

  disconnect() {
    if (this._openHandler) window.removeEventListener("open-history", this._openHandler)
  }

  open() {
    if (!this.hasBackdropTarget || !this.hasPanelTarget) return

    this.backdropTarget.classList.remove("hidden")
    this.panelTarget.classList.remove("hidden")

    requestAnimationFrame(() => {
      this.panelTarget.classList.remove("opacity-0", "scale-95")
    })

    document.documentElement.classList.add("overflow-hidden")
  }

  close() {
    if (!this.hasBackdropTarget || !this.hasPanelTarget) return

    this.panelTarget.classList.add("opacity-0", "scale-95")

    const onEnd = () => {
      this.panelTarget.classList.add("hidden")
      this.backdropTarget.classList.add("hidden")
      this.panelTarget.removeEventListener("transitionend", onEnd)
    }
    this.panelTarget.addEventListener("transitionend", onEnd, { once: true })

    document.documentElement.classList.remove("overflow-hidden")
  }

  backdropClick(e) {
    if (e.target === this.backdropTarget) this.close()
  }

  esc(e) {
    if (e.key === "Escape") this.close()
  }
}
