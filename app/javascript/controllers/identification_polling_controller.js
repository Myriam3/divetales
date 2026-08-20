import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 2000 }
  }

  connect() {
    this.poll()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  poll() {
    this.timeout = setTimeout(async () => {
      const frame = document.getElementById("identification-content")

      if (!frame) return

      try {
        const response = await fetch(window.location.href, {
          headers: {
            Accept: "text/html"
          }
        })

        const html = await response.text()

        const parser = new DOMParser()
        const document = parser.parseFromString(html, "text/html")

        const newFrame = document.querySelector(
          "#identification-content"
        )

        if (!newFrame) return

        frame.innerHTML = newFrame.innerHTML

        const stillPending = newFrame.querySelector(
          '[data-controller~="identification-polling"]'
        )

        if (stillPending) {
          this.poll()
        }

      } catch (error) {
        console.error("Identification polling error:", error)
        this.poll()
      }
    }, this.intervalValue)
  }
}
