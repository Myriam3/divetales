import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "country"]

  filter() {
    const search = this.inputTarget.value.toLowerCase().trim()

    this.element.classList.toggle("has-search", search.length > 0)

    this.countryTargets.forEach((country) => {
      const name = country.dataset.countryName.toLowerCase()
      country.hidden = !name.includes(search)
    })
  }
}
