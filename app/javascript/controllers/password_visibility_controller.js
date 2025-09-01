import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "toggle"]

  toggle() {
    const type = this.inputTarget.type === "password" ? "text" : "password"
    this.inputTarget.type = type
    this.toggleTarget.textContent = type === "password" ? "Показать" : "Скрыть"
  }
}
