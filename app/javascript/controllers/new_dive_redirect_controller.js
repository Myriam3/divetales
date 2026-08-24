// app/javascript/controllers/modal_launcher_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const modal = new bootstrap.Modal(this.element);
    const diveForm = document.getElementById("new_dive");
    modal.show();

    modal._element.addEventListener('hidden.bs.modal', () => {
      window.location.href = this.data.get("dive-path");
    });

    if (diveForm) {
      diveForm.reset();
    }
  }
}
