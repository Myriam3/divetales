import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.lastScrollTop = 0;
  }

  handleScroll() {
    const currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;

    if (currentScrollTop > this.lastScrollTop && currentScrollTop > 80) {
      this.element.classList.add("navbar--hidden");
    }
    else if (currentScrollTop < this.lastScrollTop) {
      this.element.classList.remove("navbar--hidden");
    }

    this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
  }
}
