import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "photo",
    "trip",
    "dive",
    "submit",
    "divesContainer",
    "bulkDiveId"
  ];

  static values = {
    selectedTripId: String,
    selectedDiveId: String,
    divesUrl: String
  };

  async selectTrip(event) {
    const tripId = event.target.value;

    if (!tripId) {
      this.divesContainerTarget.innerHTML = "";
      this.syncBulkDiveId("");
      this.validate();
      return;
    }

    const url = new URL(this.divesUrlValue, window.location.origin);
    url.searchParams.set("trip_id", tripId);

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/vnd.turbo-stream.html" }
      });
      const html = await response.text();
      Turbo.renderStreamMessage(html);
    } catch (error) {
      console.log(error);
      this.divesContainerTarget.innerHTML = "";
    }

    this.validate();
  }

  selectDive(event) {
    this.syncBulkDiveId(event.target.value);
    this.validate();
  }

  syncBulkDiveId(diveId) {
    this.selectedDiveIdValue = diveId;
    if (this.hasBulkDiveIdTarget) {
      this.bulkDiveIdTarget.value = diveId;
    }
  }

  validate() {
    const fileCount = this.photoTarget.files.length;
    const photo = fileCount >= 1 && fileCount <= 5;
    const dive = this.hasDiveTarget && this.diveTarget.value;
    this.submitTarget.disabled = !(photo && dive);
  }
}
