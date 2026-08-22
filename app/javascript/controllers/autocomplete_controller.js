import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "latitude", "longitude", "location"]
  static values = { url: String }

  connect() {
    // Hide the dropdown menu when the page first loads
    this.resultsTarget.classList.add("d-none")
  }

  // Called every time the user types a letter
  async search(event) {
    const query = this.inputTarget.value
    const locationId = this.locationTarget.value

    // Wait until they type at least 2 characters to avoid huge database queries
    if (query.length === 0 && !locationId) {
      this.resultsTarget.classList.add("d-none")
      return
    }

    // Fetch from your DiveSitesController
    const response = await fetch(`${this.urlValue}?query=${encodeURIComponent(query)}&location_id=${locationId}`, {
      headers: { "Accept": "application/json" }
    })
    const data = await response.json()

    this.renderResults(data)
  }

  // Builds the dropdown HTML dynamically
  renderResults(data) {
    if (data.length === 0) {
      this.resultsTarget.classList.add("d-none")
      return
    }

    // Clear old results
    this.resultsTarget.innerHTML = ""

    data.forEach((site) => {
      const button = document.createElement("button")
      button.type = "button"
      button.classList.add("list-group-item", "list-group-item-action")
      button.textContent = site.name

      // Store data on the button so we can read it when clicked
      button.dataset.action = "click->autocomplete#select"
      button.dataset.name = site.name
      button.dataset.lat = site.latitude || ""
      button.dataset.lng = site.longitude || ""

      this.resultsTarget.appendChild(button)
    })

    // Show the menu
    this.resultsTarget.classList.remove("d-none")
  }

  // Called when a user clicks a dive site from the dropdown
  select(event) {
    // Fill the visible input
    this.inputTarget.value = event.currentTarget.dataset.name

    // Fill the hidden coordinates (if your form has them)
    if (this.hasLatitudeTarget && event.currentTarget.dataset.lat) {
      this.latitudeTarget.value = event.currentTarget.dataset.lat
    }
    if (this.hasLongitudeTarget && event.currentTarget.dataset.lng) {
      this.longitudeTarget.value = event.currentTarget.dataset.lng
    }

    // Hide the dropdown
    this.resultsTarget.classList.add("d-none")
  }

  // A neat UX trick: close the dropdown if the user clicks anywhere else on the page
  hide(event) {
    if (!this.element.contains(event.target)) {
      this.resultsTarget.classList.add("d-none")
    }
  }
}
