import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  switch(event) {
    event.preventDefault()

    // 1. Identify which tab was clicked and what panel it points to
    const clickedTab = event.currentTarget
    const targetPanelId = clickedTab.dataset.targetId

    // 2. Loop through all tabs to update their active/inactive styles
    this.tabTargets.forEach((tab) => {
      if (tab === clickedTab) {
        // Apply the active styling (dark text, blue border)
        tab.classList.add("active", "text-dark", "border-bottom", "border-primary", "border-3")
        tab.classList.remove("text-secondary")
      } else {
        // Apply the inactive styling (gray text, no border)
        tab.classList.remove("active", "text-dark", "border-bottom", "border-primary", "border-3")
        tab.classList.add("text-secondary")
      }
    })

    // 3. Loop through all panels and only show the one that matches the clicked tab
    this.panelTargets.forEach((panel) => {
      if (panel.id === targetPanelId) {
        panel.classList.add("show", "active")
      } else {
        panel.classList.remove("show", "active")
      }
    })
  }
}
