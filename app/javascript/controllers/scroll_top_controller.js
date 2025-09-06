import { Controller } from "@hotwired/stimulus"

// Использование:
//   data-controller="scroll-top"
//   data-action="turbo:submit-start->scroll-top#now click->scroll-top#now"
export default class extends Controller {
  now() {
    try {
      window.scrollTo({ top: 0, behavior: "smooth" })
    } catch {
      window.scrollTo(0, 0) // фолбэк для старых браузеров
    }
  }
}