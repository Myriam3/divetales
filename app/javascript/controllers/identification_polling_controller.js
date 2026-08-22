import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 2000 },
    url: String
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
        // Use urlValue if provided, otherwise fallback to current page
        const targetUrl = this.hasUrlValue ? this.urlValue : window.location.href

        const response = await fetch(this.urlValue, {

          headers: {
            Accept: "text/html"
          }
        })

        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)

        const html = await response.text()
        const parser = new DOMParser()
        const doc = parser.parseFromString(html, "text/html")

        const newFrame = doc.getElementById("identification-content")
        const currentFrame = document.getElementById("identification-content")

        if (newFrame && currentFrame) {
          currentFrame.innerHTML = newFrame.innerHTML

          // Continue polling if the target element still has the polling controller
          const stillPending = newFrame.querySelector(
            '[data-controller~="identification-polling"]'
          )

          if (stillPending) {
            this.poll()
          } else {
            currentFrame.innerHTML = newFrame.innerHTML
          }
        }

      } catch (error) {
        console.error("Identification polling error:", error)
        this.poll()
      }
    }, this.intervalValue)
  }
}
