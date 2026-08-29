import { Controller } from "@hotwired/stimulus"
import Splide from "@splidejs/splide"

export default class extends Controller {
  static targets = ["sliderContainer"];
  static values = {
    focus: String,
    page: String,
    arrows: String,
    type: String,
    rewind: String,
    width: String,
    gap: String,
    padding: String,
    pagination: String
  };

  connect() {
    if (!this.sliderContainerTarget) return;
    this.init();
  }

  init() {
    const padding = this.paddingValue || '50px'

    const options = {
        type: this.typeValue || 'loop',
        rewind: this.arrowsValue === 'false' ? false : true,
        perMove: 1,
        focus: this.focusValue || 'center',
        arrows: this.arrowsValue === 'false' ? false : true,
        pagination: this.paginationValue === 'false' ? false : true,
        gap: '10px',
        padding: {
          left: padding,
          right: padding
        }
    }

    if (this.widthValue) {
      options.fixedWidth = Number(this.widthValue);
    } else if (this.pageValue) {
      options.perPage = this.pageValue;
    } else {
      options.perPage = 5;
    }

    console.log(options);

    this.slider = new Splide(this.sliderContainerTarget, options);

    this.slider.mount();
  }

  disconnect() {
    if (this.slider) {
      this.slider.destroy()
      this.slider = null;
    }
  }
}
