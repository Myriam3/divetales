import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    data: Array,
    pictures: Array
  }

  connect() {
    console.log(('chart'));
    this.createDepthChart();
  }

  createDepthChart() {
    const points = this.dataValue
      .map(point => ({
        x: new Date(point.timestamp),
        y: Number(point.depth)
      }))
      .filter(point => !isNaN(point.x.getTime()) && !isNaN(point.y));

    const annotations = this.mapPictures(points);

    try {
      this.chart = new window.Chart(this.canvasTarget, {
        type: "line",
        data: {
          datasets: [
            {
              label: "Depth",
              data: points,
              borderColor: "#168BCB",
              backgroundColor: "#25A7DE",
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
            },
            annotation: {
              annotations
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
    } catch(error) {
      console.log(error);
    }
  }

  mapPictures(points) {
    const annotations = {};

    this.picturesValue.forEach((picture, index) => {
      if (!picture.timestamp) return;
      const closestPoint = this.findClosestPoint(picture.timestamp, points);
      console.log(picture.categories);

      //TODO check start/end time
      annotations[`annotation${index + 1}`] = {
        type: 'label',
        //type: 'point',
        xValue: new Date(picture.timestamp),
        yValue: closestPoint.y,
        backgroundColor: 'transparent',
        content: '📷',
        borderRadius: 14,
        padding: {
          top: 0,
          left: 6,
          right: 6,
          bottom: 6
        },
        font: [{size: 24}],
        click: function({chart, element}) {
          console.log('Line picture:', picture.id, chart, element);
        }
      };
    }, {});


    return annotations;
  }

  findClosestPoint(timestamp, points) {
    const pictureTime = new Date(timestamp).getTime();
    const closestPoint = points.reduce((closest, point) => {
      const pointTime = point.x.getTime();
      const closestTime = closest.x.getTime();

      return Math.abs(pointTime - pictureTime) < Math.abs(closestTime - pictureTime)
        ? point
        : closest;
    });

    return closestPoint;
  }

  disconnect() {
    this.chart?.destroy()
  }
}
