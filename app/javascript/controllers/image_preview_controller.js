import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "container", "image"]

  preview() {
    const file = this.inputTarget.files[0]

    if (!file) {
      this.containerTarget.classList.add("d-none")
      this.imageTarget.src = ""
      return
    }

    const url = URL.createObjectURL(file)

    this.imageTarget.src = url
    this.containerTarget.classList.remove("d-none")
  }
}
