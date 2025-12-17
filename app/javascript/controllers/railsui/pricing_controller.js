import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["price", "interval", "monthBtn", "annualBtn", "promotion"]

  initialize() {
    this.interval = "month"
  }

  toggle(event) {
    // Check the current interval for the specific button clicked
    const currentInterval =
      event.currentTarget === this.monthBtnTarget ? "month" : "year"

    // If already on the selected interval, do nothing
    if (this.interval === currentInterval) {
      return
    }

    // Toggle the interval
    this.interval = currentInterval

    // Update the plan prices and intervals
    this.priceTargets.forEach((price) => {
      const monthlyPrice = price.dataset.month
      const annualPrice = price.dataset.year

      price.innerText = this.interval === "month" ? monthlyPrice : annualPrice
    })

    // Update the plan intervals
    this.intervalTargets.forEach((interval) => {
      interval.innerText = `/${this.interval}`
    })

    // Toggle button appearance
    this.monthBtnTargets.concat(this.annualBtnTargets).forEach((btn) => {
      if (event.currentTarget === btn) {
        btn.classList.remove("btn", "btn-transparent")
        btn.classList.add("btn", "btn-white")
      } else {
        btn.classList.remove("btn", "btn-white")
        btn.classList.add("btn", "btn-transparent")
      }
    })

    // Show promotion on annual plans
    this.promotionTarget.classList.toggle("hidden")
  }
}
