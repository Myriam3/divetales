import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "photo",
    "trip",
    "dive",
    "submit",
    "divesContainer",
    "bulkDiveId",
    "error",
    "previewContainer"
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
    this.updatePreviews()

    const fileCount = this.photoTarget.files.length;

    if (fileCount > 5) {
      this.errorTarget.classList.remove("d-none") // Show the error
      this.submitTarget.disabled = true           // Lock the button
      return // Stop running the rest of the validation
    } else {
      this.errorTarget.classList.add("d-none")    // Hide the error
    }

    const photo = fileCount >= 1 && fileCount <= 5;
    const dive = this.hasDiveTarget && this.diveTarget.value;
    this.submitTarget.disabled = !(photo && dive);
  }

  updatePreviews() {
    // Clear out any old previews first
    this.previewContainerTarget.innerHTML = ""

    // Convert the FileList into a standard array to loop through it
    const files = Array.from(this.photoTarget.files)

    files.forEach((file, index) => {
      // Create a temporary URL to display the image securely
      const previewUrl = URL.createObjectURL(file)

      // Build the wrapper div
      const wrapper = document.createElement("div")
      wrapper.className = "position-relative d-inline-block me-3 mb-3"

      // Build the image tag
      const img = document.createElement("img")
      img.src = previewUrl
      img.className = "rounded-3 object-fit-cover shadow-sm border"
      img.style.width = "100px"
      img.style.height = "100px"

      // Build the tiny red delete button
      const removeBtn = document.createElement("button")
      removeBtn.type = "button"
      removeBtn.className = "btn btn-danger btn-sm position-absolute top-0 start-100 translate-middle rounded-circle p-0 fw-bold d-flex align-items-center justify-content-center"
      removeBtn.style.width = "24px"
      removeBtn.style.height = "24px"
      removeBtn.innerHTML = "&times;" // Adds an 'X' symbol
      removeBtn.dataset.action = "click->picture-form#removePhoto"
      removeBtn.dataset.index = index // Save the index so we know which one to delete

      // Put it all together and drop it on the page
      wrapper.appendChild(img)
      wrapper.appendChild(removeBtn)
      this.previewContainerTarget.appendChild(wrapper)
    })
  }

  removePhoto(event) {
    event.preventDefault()

    // Find out which photo was clicked
    const indexToRemove = parseInt(event.currentTarget.dataset.index, 10)

    // The Magic: Create a brand new DataTransfer container
    const dt = new DataTransfer()
    const files = Array.from(this.photoTarget.files)

    // Add every file to the container EXCEPT the one we are deleting
    files.forEach((file, index) => {
      if (index !== indexToRemove) {
        dt.items.add(file)
      }
    })

    // Overwrite the actual HTML input with our newly filtered file list
    this.photoTarget.files = dt.files

    // Run validation again (which automatically redraws the updated previews!)
    this.validate()
  }
}
