import { Controller } from "@hotwired/stimulus"
import { Decoder, Stream, Profile, Utils } from '@garmin/fitsdk';

export default class extends Controller {
  static targets = [
    "fileInput",
    "submitButton",
    "feedback",
    "diveForm"
  ]

  connect() {
    this.feedbackTarget.textContent = ""
  }

  async importFile(event) {
    event.preventDefault();
    const file = this.fileInputTarget.files[0]

    if (!file) {
      this.showError("Please select a FIT file.")
      return
    }

    this.submitButtonTarget.disabled = true

    try {
      const arrayBuffer = await file.arrayBuffer();
      const diveData = await this.parseFitFile(arrayBuffer);

      if (diveData) {
        this.showSuccess("FIT file imported");
        this.fillDiveForm(diveData);
      }

    } catch (error) {
      this.showError(error.message || "Unable to read the FIT file.")
    } finally {
      this.submitButtonTarget.disabled = false
    }
  }

  // Parse FIT file with @garmin/fitsdk
  async parseFitFile(arrayBuffer) {
    const stream = Stream.fromArrayBuffer(arrayBuffer);
    const decoder = new Decoder(stream);

    if (!Decoder.isFIT(stream) || !decoder.checkIntegrity()) {
      this.showError("Not a valid FIT file.");
      return null;
    }

    const { messages, errors } = decoder.read();
    if (errors.length) {
      console.log('decoder errors', errors);
    }

    return messages;
  }

  fillDiveForm(data) {
    if (!this.diveFormTarget) return;

    console.log(data);

    this.setDateTime(data);
    this.setDepth(data);
    this.setTemperature(data);
    this.setCoordinates(data);
  }

  setDateTime(data) {
    const dateInput = this.diveFormTarget.dive_date;
    const durationInput = this.diveFormTarget.dive_duration;

    // Date
    const date = data.sessionMesgs[0].timestamp;
    if (date instanceof Date && dateInput.type === 'date') {
      dateInput.valueAsDate = date;
    }

    // Duration (s -> m)
    const duration = data.sessionMesgs[0].totalElapsedTime;
    const min = Math.floor(data.sessionMesgs[0].totalElapsedTime / 60);
    if (min && durationInput) {
      durationInput.value = min;
    }
  }

  setDepth(data) {
    const maxDepthInput = this.diveFormTarget.dive_max_depth;
    const avgDepthInput = this.diveFormTarget.dive_avg_depth;

    let maxDepth = data.diveSummaryMesgs[0].maxDepth
    let avgDepth = data.diveSummaryMesgs[0].avgDepth
    // TODO if empty, calculate with records

    maxDepth = isNaN(maxDepth) ? null : Number(maxDepth.toFixed(2));
    avgDepth = isNaN(avgDepth) ? null : Number(avgDepth.toFixed(2));

    if (maxDepthInput && maxDepth) {
      maxDepthInput.value = maxDepth;
    }

    if (avgDepthInput && avgDepth) {
      avgDepthInput.value = avgDepth;
    }
  }

  setTemperature(data) {
    const maxTempInput = this.diveFormTarget.dive_max_temp;
    const minTempInput = this.diveFormTarget.dive_min_temp;
    const avgTempInput = this.diveFormTarget.dive_avg_temp;

    let maxTemp = data.sessionMesgs[0].maxTemperature
    let minTemp = data.sessionMesgs[0].minTemperature
    let avgTemp = data.diveSummaryMesgs[0].avgTemperature
    // TODO if empty, calculate with records

    maxTemp = isNaN(maxTemp) ? null : Number(maxTemp.toFixed(2));
    minTemp = isNaN(minTemp) ? null : Number(minTemp.toFixed(2));
    avgTemp = isNaN(avgTemp) ? null : Number(avgTemp.toFixed(2));

    if (maxTempInput && maxTemp) {
      maxTempInput.value = maxTemp;
    }

    if (minTempInput && minTemp) {
      minTempInput.value = minTemp;
    }

    if (minTempInput && avgTemp) {
      minTempInput.value = avgTemp;
    }
  }

  setCoordinates(data) {
    const latInput = this.diveFormTarget.dive_latitude;
    const longInput = this.diveFormTarget.dive_longitude;
    let lat = data.sessionMesgs[0].startPositionLat;
    let long = data.sessionMesgs[0].startPositionLong;
    console.log(lat, long);


    lat = this.convertSemicircles(lat);
    long = this.convertSemicircles(long);
    // TODO dive site with geocode API?

    if (latInput && lat) {
      latInput.value = lat;
    } else {
      return;
    }

    if (longInput && long) {
      longInput.value = long;
    }
  }

  showSuccess(message) {
    this.feedbackTarget.textContent = message
    this.feedbackTarget.className = "alert alert-success"
  }

  showError(message) {
    this.feedbackTarget.textContent = message
    this.feedbackTarget.className = "alert alert-danger"
  }

  // Semicircles to lat/long
  convertSemicircles(num) {
    return isNaN(num) ? null : Number(num * (180 / Math.pow(2, 31))).toFixed(6);
  }
}
