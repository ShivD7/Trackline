import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  async copy() {
    const originalLabel = this.element.textContent

    try {
      await navigator.clipboard.writeText(this.textValue)
      this.element.textContent = "Copied"
    } catch (_error) {
      this.element.textContent = "Copy failed"
    }

    window.setTimeout(() => { this.element.textContent = originalLabel }, 1500)
  }
}
