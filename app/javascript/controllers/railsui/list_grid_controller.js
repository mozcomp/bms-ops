import { Controller } from "@hotwired/stimulus"

const BUTTON_CLASSES = ["text-primary-500", "dark:text-primary-500"]

export default class extends Controller {
  static targets = ["grid", "gridButton", "list", "listButton"]
  static values = {
    activeType: { type: String, default: "grid" },
  }

  connect() {
    this.toggleView(this.activeTypeValue)
  }

  toggle(event) {
    const type = event.target === this.gridButtonTarget ? "grid" : "list"
    this.toggleView(type)
  }

  toggleView(type) {
    if (type === "grid") {
      this.showView(this.gridTarget, this.gridButtonTarget)
      this.hideView(this.listTarget, this.listButtonTarget)
    } else {
      this.showView(this.listTarget, this.listButtonTarget)
      this.hideView(this.gridTarget, this.gridButtonTarget)
    }
  }

  showView(view, button) {
    view.classList.remove("hidden")
    this.setButtonActive(button)
  }

  hideView(view, button) {
    view.classList.add("hidden")
    button.querySelector("svg").classList.remove(...BUTTON_CLASSES)
  }

  setButtonActive(button) {
    button.querySelector("svg").classList.add(...BUTTON_CLASSES)
  }
}
