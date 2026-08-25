import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    data: Array
  }

  connect() {
    console.log(('chart'));
    this.createDepthChart();
  }

  createDepthChart() {
    console.log(JSON.stringify(this.dataValue));
    const points = this.dataValue
      .map(point => ({
        x: new Date(point.timestamp),
        y: Number(point.depth)
      }))
      .filter(point => !isNaN(point.x.getTime()) && !isNaN(point.y));

    this.chart = new window.Chart(this.canvasTarget, {
      type: "line",
      data: {
        datasets: [
          {
            label: "Depth",
            data: points,
            borderColor: "#0d6efd",
            backgroundColor: "#92bbfa",
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
        interaction: {
          intersect: false,
          mode: 'index',
        },
        scales: {
          x: {
            type: "time",
            time: {
              unit: "minute",
              tooltipFormat: "HH:mm"
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
        },
        plugins: {
          title: {
            display: true,
            text: 'Depth over time'
          },
          legend: {
            display: false
          },
          tooltip: {
            displayColors: false,
          }
        },
        transitions: {
          show: {
            animations: {
              x: {
                from: 0
              },
              y: {
                from: 0
              }
            }
          },
          hide: {
            animations: {
              x: {
                to: 0
              },
              y: {
                to: 0
              }
            }
          }
        }
      }
    });
  }

  disconnect() {
    this.chart?.destroy()
  }
}
