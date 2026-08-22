import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["formContent", "jellyfishUI", "sourceImage", "destinationImage"]

  showLoading(event) {
    // 1. Hide the form inputs
    this.formContentTarget.classList.add("d-none")

    // 2. Show the Jellyfish animation
    this.jellyfishUITarget.classList.remove("d-none")

    // 3. Instantly copy the local preview over to the loading screen!
    if (this.hasSourceImageTarget && this.hasDestinationImageTarget) {
      this.destinationImageTarget.src = this.sourceImageTarget.src
    }
  }
}
