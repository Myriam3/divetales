import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "latitude", "longitude", "location"]
  static values = { url: String }

  connect() {
    this.resultsTarget.classList.add("d-none")
  }

  async search(event) {
    const query = this.inputTarget.value
    const locationId = this.locationTarget.value

    if (query.length === 0 && !locationId) {
      this.resultsTarget.classList.add("d-none")
      return
    }

    const response = await fetch(`${this.urlValue}?query=${encodeURIComponent(query)}&location_id=${locationId}`, {
      headers: { "Accept": "application/json" }
    })
    const data = await response.json()

    this.renderResults(data)
  }

  renderResults(data) {
    if (data.length === 0) {
      this.resultsTarget.classList.add("d-none")
      return
    }

    this.resultsTarget.innerHTML = ""

    data.forEach((site) => {
      const button = document.createElement("button")
      button.type = "button"
      // Added styling classes for the two-line layout
      button.classList.add("list-group-item", "list-group-item-action", "text-start", "py-2")

      // 1. Create the main dive site name
      const nameDiv = document.createElement("div")
      nameDiv.textContent = site.name
      nameDiv.classList.add("fw-bold")

      // 2. Create the subtitle (Location Name or GPS)
      const detailsDiv = document.createElement("small")
      detailsDiv.textContent = site.details // Uses the detail string from your Rails controller
      detailsDiv.classList.add("text-muted", "d-block")

      button.appendChild(nameDiv)
      button.appendChild(detailsDiv)

      // Store data on the button so we can read it when clicked
      button.dataset.action = "click->autocomplete-divesite#select"
      button.dataset.name = site.name
      button.dataset.lat = site.latitude || ""
      button.dataset.lng = site.longitude || ""

      this.resultsTarget.appendChild(button)
    })

    this.resultsTarget.classList.remove("d-none")
  }

  select(event) {
    this.inputTarget.value = event.currentTarget.dataset.name

    if (this.hasLatitudeTarget && event.currentTarget.dataset.lat) {
      this.latitudeTarget.value = event.currentTarget.dataset.lat
    }
    if (this.hasLongitudeTarget && event.currentTarget.dataset.lng) {
      this.longitudeTarget.value = event.currentTarget.dataset.lng
    }

    this.resultsTarget.classList.add("d-none")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.resultsTarget.classList.add("d-none")
    }
  }
}
