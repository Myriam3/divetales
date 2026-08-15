import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["info", "button"]

  toggle() {
    this.infoTargets.forEach((element) => {
      element.classList.toggle("d-none")
    })

    const hidden = this.infoTargets[0].classList.contains("d-none")

    this.buttonTarget.textContent = hidden ? "Show info" : "Hide info"
  }
}
