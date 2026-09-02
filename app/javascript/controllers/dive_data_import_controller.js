import { Controller } from "@hotwired/stimulus"
import { Decoder, Stream, Profile, Utils } from '@garmin/fitsdk';

export default class extends Controller {
  static targets = [
    "fileInput",
    "submitButton",
    "feedback",
    "diveForm",
    "mapInfoContainer"
  ];

  connect() {
    this.feedbackTarget.textContent = "";
  }

  // Import file
  async importFile(event) {
    event.preventDefault();
    const file = this.fileInputTarget.files[0];

    if (!file) {
      this.showError("Please select a FIT file.");
      return;
    }

    this.submitButtonTarget.disabled = true

    try {
      const arrayBuffer = await file.arrayBuffer();
      const diveData = await this.parseFitFile(arrayBuffer);

      if (!diveData) return;
      this.showSuccess("FIT file imported");
      this.fillDiveForm(diveData);
      this.setDepthProfile(diveData);

    } catch (error) {
        console.log(error);
      this.showError("Unable to read the FIT file.");
    } finally {
        this.submitButtonTarget.disabled = false;
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

  // Timezone offset in s
  getTimeOffset(data) {
    if (!data.deviceSettingsMesgs?.length || !data.deviceSettingsMesgs[0].timeOffset?.length) return
    return Number(data.deviceSettingsMesgs[0].timeOffset[0]) || 0;
  }

  // Update the new dive form
  fillDiveForm(data) {
    if (!this.diveFormTarget) return;

    this.setDiveNumber(data);
    this.setDateTime(data);
    this.setDepth(data);
    this.setTemperature(data);
    this.setGas(data);
    this.setCoordinates(data);
  }

  // Dive number
  setDiveNumber(data) {
    const diveNumberInput = this.diveFormTarget.dive_dive_number;
    const number = data.diveSummaryMesgs[1]?.diveNumber;

    if (diveNumberInput && number) {
      diveNumberInput.value = number
    }
  }

  // Date, time, duration
  setDateTime(data) {
    const dateInput = this.diveFormTarget.dive_date;
    const startTimeInput = this.diveFormTarget.dive_start_time;
    const endTimeInput = this.diveFormTarget.dive_end_time;
    const durationInput = this.diveFormTarget.dive_duration;

    // Duration (s -> m)
    const duration = data.sessionMesgs[0]?.totalElapsedTime;
    const min = Math.floor(data.sessionMesgs[0]?.totalElapsedTime / 60);
    if (min && durationInput) {
      durationInput.value = min;
    }

    // Date
    const startDate = data.sessionMesgs[0]?.startTime;
    if (!(startDate instanceof Date)) return;

    if (dateInput && dateInput.type === 'date') {
      dateInput.value = this.formatTimestamp(startDate, data).split('T')[0];
    }

    // Time
    //const startTime = this.convertDatetime(startDate);
    const startTime = this.formatTimestamp(startDate, data);
    if (startTimeInput && startTimeInput.type === 'datetime-local') {
      startTimeInput.value = startTime;
    }

    const endDate = data.sessionMesgs[0]?.timestamp;
    //const endtime = endDate ?  this.convertDatetime(endDate) : this.calculateEndTime(startDate, duration);
    const endtime = endDate ? this.formatTimestamp(endDate, data) : null;
    // TODO check endtime

    if (endTimeInput && endTimeInput.type === 'datetime-local') {
      endTimeInput.value  = endtime;
    }
  }

  calculateEndTime(startDate, duration) {
    return this.convertDatetime(new Date(startDate.getTime() + duration * 1000));
  }

  // Date to YYYY-MM-DDTHH:mm
  convertDatetime(date) {
    const offset = date.getTimezoneOffset() * 60000;
    return new Date(date.getTime() - offset).toISOString().slice(0, 16);
  }

  // Depth
  setDepth(data) {
    const maxDepthInput = this.diveFormTarget.dive_max_depth;
    const avgDepthInput = this.diveFormTarget.dive_avg_depth;

    let maxDepth = data.diveSummaryMesgs[0]?.maxDepth
    let avgDepth = data.diveSummaryMesgs[0]?.avgDepth
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

  // Temperature
  setTemperature(data) {
    const maxTempInput = this.diveFormTarget.dive_max_temp;
    const minTempInput = this.diveFormTarget.dive_min_temp;
    const avgTempInput = this.diveFormTarget.dive_avg_temp;

    let maxTemp = data.sessionMesgs[0]?.maxTemperature
    let minTemp = data.sessionMesgs[0]?.minTemperature
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

  // Coordinates
  setCoordinates(data) {
    const latInput = this.diveFormTarget.dive_latitude;
    const longInput = this.diveFormTarget.dive_longitude;

    let lat = data.sessionMesgs[0]?.startPositionLat;
    let long = data.sessionMesgs[0]?.startPositionLong;

    lat = this.convertSemicircles(lat);
    long = this.convertSemicircles(long);

    if (latInput && lat) {
      latInput.value = lat;
    } else {
      return;
    }

    if (!(longInput && long)) return;

    longInput.value = long;

    this.dispatch("import-coordinates", {
      detail: { lat, long },
      bubbles: true
    });
  }

  // Semicircles to lat/long
  convertSemicircles(num) {
    return isNaN(num) ? null : Number(num * (180 / Math.pow(2, 31))).toFixed(6);
  }

  // Gas
  setGas(data) {
    const tankTypeInput = this.diveFormTarget.dive_tank_type;
    const gasInfo = data.diveGasMesgs ? data.diveGasMesgs[0] : null;
    if (!gasInfo || !tankTypeInput) return;

    if (Math.floor(gasInfo.heliumContent) > 0) {
      tankTypeInput.value = "trimix"
    } else if (Math.floor(gasInfo.oxygenContent) > 21) {
      tankTypeInput.value = "nitrox"
    } else {
      tankTypeInput.value = "air"
    }
  }

  // Depth profile
  setDepthProfile(data) {
    const records = data.recordMesgs;
    const input = this.diveFormTarget.dive_depth_over_time;

    if (!(records && records.length && input)) return;

    const depthProfile = this.getDepthRecords(records, data);
    input.value = JSON.stringify(depthProfile);
  }

  getDepthRecords(records, data) {
    return records.map((record) => {
      return {
        timestamp: this.formatTimestamp(record.timestamp, data),
        depth: record.depth
      }
    });
  }

  formatTimestamp(date, data) {
    const timeOffset = this.getTimeOffset(data);
    // timeOffset FIT = secondes
    const offsetTime = new Date(
      date.getTime() + Number(timeOffset) * 1000
    );

    const pad = (value, length = 2) =>
      String(value).padStart(length, "0");

    return `${offsetTime.getUTCFullYear()}-${pad(offsetTime.getUTCMonth() + 1)}-${pad(offsetTime.getUTCDate())}` +
      `T${pad(offsetTime.getUTCHours())}:${pad(offsetTime.getUTCMinutes())}:${pad(offsetTime.getUTCSeconds())}.${pad(offsetTime.getUTCMilliseconds(), 3)}`;
  }

  // Location selector update
  selectLocation(e) {
    const diveLocationSelect = this.diveFormTarget.dive_location_id;
    if (!(e.detail?.name && diveLocationSelect)) return;
    const words = e.detail.name.split(",");
    let options = Array.from(diveLocationSelect.options);

    if (e.detail.countryCode) {
      options = options.filter((opt) => opt.parentElement.getAttribute('data-country-code') === e.detail.countryCode);
    }

    for (let i = 1; i < options.length; i++) {
      const label = options[i].label.toLowerCase();
      const match = words.some(word => label.includes(word.toLowerCase().replace(' ', '')));

      if (match) {
        diveLocationSelect.selectedIndex = options[i].index;
        return;
      } else {
        diveLocationSelect.selectedIndex = 0;
      }
    }
  }

  // Messages
  showSuccess(message) {
    this.feedbackTarget.textContent = message
    this.feedbackTarget.className = "alert alert-success"
  }

  showError(message) {
    this.feedbackTarget.textContent = message
    this.feedbackTarget.className = "alert alert-danger"
  }
}
