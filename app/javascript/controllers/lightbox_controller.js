import { Controller } from "@hotwired/stimulus"
import Splide from "@splidejs/splide"

export default class extends Controller {
  static targets = [
    "dialog",
    "content",
    "slider"
  ];

  connect() {
    this.slider = null;
    this.opening = false;
    this.options = {
        type: 'loop',
        perMove: 1,
        //focus: 'center',
        arrows: true,
        pagination: true,
        //updateOnMove : true,
        gap: '10px'
    }
  }

  open(e) {
    console.log(e);
    if (this.dialogTarget.tagName !== 'DIALOG') return;
    this.contentTarget.classList.remove('visible');
    this.dialogTarget.style.display = 'block';

    window.setTimeout(() => {
      this.dialogTarget.showModal();
      this.contentTarget.classList.add('visible');
    }, 200);
  }

  close() {
    if (this.dialogTarget.tagName !== 'DIALOG') return;
    this.dialogTarget.close();
    this.dialogTarget.style.display = 'none';
    this.contentTarget.classList.remove('visible');
  }

  sliderTargetConnected() {
    this.createSlider();
  }

  createSlider() {
    this.options.start = Number(this.sliderTarget.getAttribute('data-start'));
    this.slider = new Splide(this.sliderTarget, this.options);
    this.slider.mount();
  }

  disconnect() {
    this.dialogTarget.close();
    this.observer?.disconnect();
  }
}
