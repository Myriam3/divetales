import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content", "matchesContainer", "refineForm"]

  show(event) {
    const clickedTab = event.currentTarget
    const index = this.tabTargets.indexOf(clickedTab)

    // Remove active state from all tabs
    this.tabTargets.forEach((tab) => {
      tab.classList.remove("active")
    })

    // Hide all result contents
    this.contentTargets.forEach((content) => {
      content.classList.add("d-none")
    })

    // Activate clicked tab
    clickedTab.classList.add("active")
    this.contentTargets[index].classList.remove("d-none")
  }

  toggleForm(event) {
    this.refineFormTarget.classList.toggle("d-none")

    if (this.refineFormTarget.classList.contains("d-none")) {
      this.matchesContainerTarget.classList.remove("d-none")
      event.target.innerText = "Add more context & try again"
      event.target.classList.replace("btn-outline-danger", "btn-outline-primary")
    } else {
      this.matchesContainerTarget.classList.add("d-none")
      event.target.innerText = "Cancel / Back to matches"
      event.target.classList.replace("btn-outline-primary", "btn-outline-danger")
    }
  }
}
