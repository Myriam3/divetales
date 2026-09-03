import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    data: Array,
    pictures: Array,
    icon: String,
    syncSlider: String
  }

  connect() {
    this.chartBorderColor = '#2588E4';
    this.chartBgColor = '#7FB9F0';
    this.chartBorderWidth = 2;
    this.iconColor = '#FFFFF';
    this.iconBgColor = '#145DA0';
    this.iconBgColorSelected = "#E9634B";
    this.selectedId = null;

    this.init();
  }

  init() {
    const points = this.dataValue
      .map(point => ({
        x: new Date(point.timestamp),
        y: Number(point.depth)
      }))
      .filter(point => !isNaN(point.x.getTime()) && !isNaN(point.y));

    const pictureLabels = this.picturesValue.length && this.syncSliderValue== "true" ? this.mapPictures(points) : {};
    this.createDepthChart(points, pictureLabels);
  }

  createDepthChart(points, annotations){
    try {
      this.chart = new window.Chart(this.canvasTarget, {
        type: "line",
        data: {
          datasets: [
            {
              label: "Depth",
              data: points,
              borderColor: this.chartBorderColor,
              backgroundColor: this.chartBgColor,
              borderWidth: this.chartBorderWidth,
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

  // Map pictures with chart data
  mapPictures(points) {
    const annotations = {};
    const start = points[0].x;
    const end = points[points.length - 1].x;

    this.picturesValue.forEach((picture, index) => {
      if (!picture.timestamp) return;
      const closestPoint = this.findClosestPoint(picture.timestamp, points);
      const pictureDate = new Date(picture.timestamp);
      if (!(pictureDate >= start && pictureDate <= end)) return;

      let icon = '📷';
      if (this.iconValue) {
        icon = document.createElement('img');
        icon.src = this.iconValue;
        icon.width = 18;
        icon.height = 18;
        icon.alt = "Picture";
      }

      annotations[picture.id] = {
        type: 'label',
        //type: 'point',
        xValue: new Date(picture.timestamp),
        yValue: closestPoint.y,
        color: this.iconColor,
        backgroundColor: this.iconBgColor,
        content: icon,
        drawTime: 'afterDraw',
        borderRadius: 24,
        padding: {
          top: 6,
          left: 6,
          right: 6,
          bottom: 6
        },
        font: [{size: 20}],
        click: (e) => {
          const element = e.element;
          this.dispatch("picture-selected", {
            detail: { picture, element }
          });
        }
      };
    }, {});

    return annotations;
  }

  // Toggle annotation (in sync with slideer)
  toggleLabel(e) {
    const newId = e.detail.pictureId;
    if (e.type !== 'slider:slider-active' || newId === this.selectedId) return;
    const newItem = this.chart.options.plugins.annotation.annotations[newId];
    const currentItem = this.selectedId ? this.chart.options.plugins.annotation.annotations[this.selectedId] : null;

    if (newItem) newItem.backgroundColor = this.iconBgColorSelected;
    if (currentItem) currentItem.backgroundColor = this.iconBgColor;

    this.selectedId = newId;
    this.chart.update();
  }

  // Find closest timestamp point
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
    this.chart?.destroy();
  }
}
