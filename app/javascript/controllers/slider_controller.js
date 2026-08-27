import { Controller } from "@hotwired/stimulus"
import Splide from "@splidejs/splide"

export default class extends Controller {
  static targets = ["sliderContainer"];
  static values = {
    focus: String
  };

  connect() {
    if (!this.sliderContainerTarget) return;
    this.init();
  }

  init() {
    this.slider = new Splide(this.sliderContainerTarget,
      {
        type   : 'loop',
        perPage: 5,
        //rewind: false,
        //perMove: 1,
        //focus  : 'center',
        gap: "10px",
        padding: {
          left: '50px',
          right: '50px'
        }
      }
    );

    this.slider.mount();
  }

  disconnect() {
    if (this.slider) {
      this.slider.destroy()
      this.slider = null;
    }
  }
}
