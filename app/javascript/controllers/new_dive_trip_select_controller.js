// app/javascript/controllers/modal_launcher_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tripSelector"
  ];

  connect() {
    const modal = new bootstrap.Modal(this.element);
    console.log(this.element, this.tripSelector);
  }
}
