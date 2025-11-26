import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "backdrop"]

  toggle() {
    const drawer = document.querySelector('[data-sidebar-target="drawer"]')
    const backdrop = document.querySelector('[data-sidebar-target="backdrop"]')
    
    if (drawer && backdrop) {
      drawer.classList.toggle("-translate-x-full")
      backdrop.classList.toggle("hidden")
    }
  }

  close() {
    const drawer = document.querySelector('[data-sidebar-target="drawer"]')
    const backdrop = document.querySelector('[data-sidebar-target="backdrop"]')
    
    if (drawer && backdrop) {
      drawer.classList.add("-translate-x-full")
      backdrop.classList.add("hidden")
    }
  }
}
