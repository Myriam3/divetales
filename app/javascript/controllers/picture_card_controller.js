import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "info",
    "button",
    "buttonShow",
    "buttonHide"
  ];

  connect() {
    this.toggled = false;
  }

  toggle() {
    this.infoTargets.forEach((element) => {
      element.classList.toggle("d-none");
    });

    this.toggled = !this.toggled;

    if (this.toggled) {
      this.buttonShowTarget.classList.add('d-none');
      this.buttonHideTarget.classList.remove('d-none');
    } else {
      this.buttonShowTarget.classList.remove('d-none');
      this.buttonHideTarget.classList.add('d-none');    }
  }
}
