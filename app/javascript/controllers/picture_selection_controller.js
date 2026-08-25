import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectButton", "cancelButton", "deleteButton", "checkboxWrapper", "checkbox"]
  static values = { selecting: Boolean }

  toggleMode(event) {
    if (event) event.preventDefault()
    this.selectingValue = !this.selectingValue

    if (this.selectingValue) {
      // Enter selection mode
      this.selectButtonTarget.classList.add("d-none")
      this.cancelButtonTarget.classList.remove("d-none")
      this.checkboxWrapperTargets.forEach(el => el.classList.remove("d-none"))
    } else {
      // Exit selection mode
      this.selectButtonTarget.classList.remove("d-none")
      this.cancelButtonTarget.classList.add("d-none")
      this.checkboxWrapperTargets.forEach(el => el.classList.add("d-none"))
      this.deleteButtonTarget.classList.add("d-none")

      // Uncheck everything
      this.checkboxTargets.forEach(cb => cb.checked = false)
    }
  }

  checkSelection() {
    const anyChecked = this.checkboxTargets.some(cb => cb.checked)
    if (anyChecked) {
      this.deleteButtonTarget.classList.remove("d-none")
    } else {
      this.deleteButtonTarget.classList.add("d-none")
    }
  }

  preventNavigation(event) {
    // If we are in selection mode, stop the link from opening the picture
    if (this.selectingValue) {
      event.preventDefault()

      // Toggle the checkbox for the clicked picture instead
      const checkbox = event.currentTarget.closest('.card').querySelector('input[type="checkbox"]')
      if (checkbox) {
        checkbox.checked = !checkbox.checked
        this.checkSelection()
      }
    }
  }
}
