import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "panel"]

  connect() {
    console.log("[modal] connect", {
      hasBackdrop: this.hasBackdropTarget,
      hasPanel: this.hasPanelTarget
    })
  }

  open() {
    if (!this.hasBackdropTarget || !this.hasPanelTarget) {
      console.warn("[modal] no targets found")
      return
    }

    this.backdropTarget.classList.remove("hidden")
    this.panelTarget.classList.remove("hidden")

    this.panelTarget.style.width = "50%"
    this.panelTarget.style.height = "35%"
    this.panelTarget.style.position = "absolute"
    this.panelTarget.style.left = "25%"
    this.panelTarget.style.margin = "0"
    this.panelTarget.style.top = "25%"

    // плавное появление панели
    requestAnimationFrame(() => {
      this.panelTarget.classList.remove("opacity-0", "scale-95")
    })

    this.backdropTarget.style.height = "100%"
    this.backdropTarget.style.width = "100%"
    this.backdropTarget.style.top = "0"
    this.backdropTarget.style.opacity = "100"
    this.backdropTarget.style.background = "#00000043"

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

    this.backdropTarget.style.height = "0"
    this.backdropTarget.style.width = "0"
    this.backdropTarget.style.top = "0"
    this.backdropTarget.style.opacity = "0"

    this.panelTarget.style.height = "0"
    this.panelTarget.style.width = "0"
    this.panelTarget.style.top = "0"
  }

  backdropClick(e) {
    if (e.target === this.backdropTarget) this.close()
  }

  esc(e) {
    if (e.key === "Escape") this.close()
  }
}
