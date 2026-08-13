import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

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
}
