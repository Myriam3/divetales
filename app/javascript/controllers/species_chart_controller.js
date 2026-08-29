import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "details"]

  static values = {
    labels: Array,
    data: Array,
    categories: Object
  }

  static classColors = {
    other: "#9CA3AF",
    fish: "#3B82F6",
    mammal: "#8B5CF6",
    reptile: "#22C55E",
    crustacean: "#F97316",
    mollusk: "#06B6D4",
    cnidarian: "#EC4899",
    echinoderm: "#EAB308",
    annelid: "#A855F7",
    sponge: "#14B8A6"
  }

  connect() {
    this.chart = new Chart(this.canvasTarget, {
      type: "pie",

      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.dataValue,
          backgroundColor: this.colors()
        }]
      },

      options: {
        responsive: true,

        plugins: {
          legend: {
            position: "right"
          }
        },

        onClick: (_event, elements) => {
          if (elements.length === 0) return

          const index = elements[0].index
          const classification = this.labelsValue[index]

          this.showCategories(classification)
        }
      }
    })
  }

  colors() {
    return this.labelsValue.map(label => {
      return this.constructor.classColors[label.toLowerCase()] || "#9CA3AF"
    })
  }

  showCategories(classification) {
    const categories = this.categoriesValue[classification] || []

    if (categories.length === 0) {
      this.detailsTarget.innerHTML = `
        <p>Aucune catégorie pour cette classification.</p>
      `
      return
    }

    this.detailsTarget.innerHTML = `
      <h3>${classification}</h3>
      <ul>
        ${categories.map(category => `<li>${category}</li>`).join("")}
      </ul>
    `
  }

  disconnect() {
    this.chart?.destroy()
  }
}
