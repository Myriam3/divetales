import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    data: Array
  }

  connect() {
    const points = this.dataValue
      .map(point => ({
        x: new Date(point.timestamp),
        y: Number(point.depth)
      }))
      .filter(point => !isNaN(point.x.getTime()) && !isNaN(point.y))

    this.chart = new window.Chart(this.canvasTarget, {
      type: "line",

      data: {
        datasets: [
          {
            label: "Depth over time",
            data: points,
            borderColor: "#0d6efd",
            backgroundColor: "rgba(13, 110, 253, 0.15)",
            borderWidth: 2,
            pointRadius: 0,
            tension: 0.3,
            fill: true
          }
        ]
      },

      options: {
        responsive: true,
        maintainAspectRatio: false,

        scales: {
          x: {
            type: "time",
            time: {
              unit: "minute",
              tooltipFormat: "dd/MM/yyyy HH:mm"
            },
            title: {
              display: true,
              text: "Time"
            }
          },

          y: {
            reverse: true,
            title: {
              display: true,
              text: "Depth (m)"
            }
          }
        }
      }
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
