import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.lastScrollTop = 0;
  }

  handleScroll() {
    const currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;

    // Scroll Down: Hide navbar (only if scrolled past 80px to avoid glitching at the very top)
    if (currentScrollTop > this.lastScrollTop && currentScrollTop > 80) {
      this.element.classList.add("navbar--hidden");
    }
    // Scroll Up: Show navbar
    else if (currentScrollTop < this.lastScrollTop) {
      this.element.classList.remove("navbar--hidden");
    }

    // Prevent negative values when elastic-bouncing at the top on Safari/iOS
    this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
  }
}
