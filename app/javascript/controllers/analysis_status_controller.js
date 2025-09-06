import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["line"]
  static values = { url: String }

  connect() {
    this.phrases = [
      "анализирую аудио файл…",
      "ищу закономерности…",
      "подготавливаю ответ…",
      "формирую отчёт…"
    ]
    this.i = 0
    this.rotate = setInterval(() => this.tick(), 1800)
    this.poll()
  }

  disconnect() {
    if (this.rotate) clearInterval(this.rotate)
    if (this.pollTimer) clearTimeout(this.pollTimer)
  }

  tick() {
    if (!this.hasLineTarget) return
    this.lineTarget.textContent = this.phrases[this.i % this.phrases.length]
    this.i += 1
  }

  poll() {
    if (!this.urlValue) return
    fetch(this.urlValue, { headers: { "Accept": "application/json" } })
      .then(r => r.json())
      .then(data => {
        if (data.done || data.failed) {
          window.location.reload()
          return
        }
        this.pollTimer = setTimeout(() => this.poll(), 2000)
      })
      .catch(() => {
        this.pollTimer = setTimeout(() => this.poll(), 3000)
      })
  }
}
