import { Controller } from "@hotwired/stimulus"

// data-controller="analysis-status"
// data-analysis-status-url-value="/analyses/:id.json"
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
    clearInterval(this.rotate)
    clearTimeout(this.pollTimer)
  }

  tick() {
    if (!this.hasLineTarget) return
    this.i = (this.i + 1) % this.phrases.length
    this.lineTarget.textContent = this.phrases[this.i]
  }

  poll() {
    fetch(this.urlValue, { headers: { "Accept": "application/json" }})
      .then(r => r.json())
      .then(data => {
        if (data.done || data.failed) {
          // перерисуем карточку целиком (перейдём на HTML-шаблон без прелоадера)
          window.location.reload()
          return
        }
        // повторный опрос
        this.pollTimer = setTimeout(() => this.poll(), 2000)
      })
      .catch(() => {
        // попробуем ещё раз через 3 сек
        this.pollTimer = setTimeout(() => this.poll(), 3000)
      })
  }
}
