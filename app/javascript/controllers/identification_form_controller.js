import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "question"]

  toggle(event) {
    const clickedQuestion = event.currentTarget
    const index = this.questionTargets.indexOf(clickedQuestion)
    const clickedContent = this.contentTargets[index]

    const isOpen = !clickedContent.classList.contains("d-none")

    // Close all sections
    this.contentTargets.forEach((content) => {
      content.classList.add("d-none")
    })

    // Reset all buttons
    this.questionTargets.forEach((question) => {
      question.classList.remove("active")
    })

    // Open clicked section
    if (!isOpen) {
      clickedContent.classList.remove("d-none")
      clickedQuestion.classList.add("active")
    }
  }
}
