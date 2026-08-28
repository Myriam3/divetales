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
    paddingLeft: String,
    pagination: String,
    trimSpace: String,
    autoWidth: String
  };

  connect() {
    if (!this.sliderContainerTarget) return;
    this.slidePictures = {};
    this.currentSelected = null;
    this.init();
  }

  init() {
    const padding = this.paddingValue || '0'
    const trimSpace = this.trimSpaceValue === 'false' ? false : (this.trimSpaceValue || true)
    const options = {
        type: this.typeValue || 'loop',
        rewind: this.arrowsValue === 'false' ? false : true,
        perMove: 1,
        focus: this.focusValue || 'center',
        arrows: this.arrowsValue === 'false' ? false : true,
        pagination: this.paginationValue === 'false' ? false : true,
        updateOnMove : true,
        gap: this.gapValue || '10px',
        trimSpace,
        padding: {
          left: this.paddingLeftValue || padding,
          right: padding
        }
    }

    if (this.autoWidthValue === 'true') {
      options.autoWidth = true;
      //options.omitEnd = true;
    }
    else if (this.widthValue) {
      options.fixedWidth = this.widthValue;
      //options.omitEnd = true;
    } else if (this.pageValue) {
      options.perPage = this.pageValue;
    } else {
      options.perPage = 5;
    }

    //console.log(options);

    this.slider = new Splide(this.sliderContainerTarget, options);
    this.slider.mount();

    this.slider.Components.Slides.forEach((item) => {
      const id = item.slide.getAttribute('data-id');
      if (!id) return;

      this.slidePictures[id] = {
        index: item.index,
        el: item.slide
      };
    });
  }

  selectPicture(e) {
    const picture = e.detail?.picture;
    if (!picture) return;

    const selected = this.slidePictures[picture.id];
    if (!selected) return;

    if (this.currentSelected) {
      this.currentSelected.el.classList.remove('is-selected');
    }

    if (this.currentSelected === selected) {
      this.currentSelected = null;
      return;
    }

    this.slider.go(selected.index);
    selected.el.classList.add('is-selected');
    this.currentSelected = selected;
    //this.slider.root.style.minHeight = this.slider.root.offsetHeight;
  }

  unselectPicture(e) {

  }

  disconnect() {
    if (this.slider) {
      this.slider.destroy()
      this.slider = null;
    }

    this.slidePictures = {};
    this.currentSelected = null;
  }
}
