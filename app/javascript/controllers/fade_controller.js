import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const box = document.getElementById("analysis_stream_target")
    if (!box) return

    // плавно прячем контейнер
    box.classList.add("transition-opacity", "duration-300", "opacity-0")

    // после анимации — очищаем содержимое и возвращаем непрозрачность
    setTimeout(() => {
      box.innerHTML = ""
      box.classList.remove("opacity-0")
    }, 320)

    // сам маркер можно удалить
    this.element.remove()
  }
}
