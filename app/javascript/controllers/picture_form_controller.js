import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "photo",
    "trip",
    "dive",
    "submit",
    "divesContainer"
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


  validate() {
    const photo = this.photoTarget.files.length > 0;
    const dive = this.hasDiveTarget && this.diveTarget.value;
    this.submitTarget.disabled = !(photo && dive);
  }
}
