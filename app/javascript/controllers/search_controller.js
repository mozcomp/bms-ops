import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  filter(event) {
    const query = event.target.value.toLowerCase()
    // TODO: Implement search filtering logic
    console.log("Searching for:", query)
  }
}
