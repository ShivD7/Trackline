import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]

  connect() {
    this.abortController = new AbortController()
    this.linkTargets.forEach(link => {
      const field = document.getElementById(link.hash.slice(1))
      if (!field) {
        link.replaceWith(document.createTextNode(link.textContent))
        return
      }

      field.setAttribute("aria-invalid", "true")
      const descriptions = new Set((field.getAttribute("aria-describedby") || "").split(" ").filter(Boolean))
      descriptions.add(this.element.id)
      field.setAttribute("aria-describedby", [...descriptions].join(" "))
      link.addEventListener("click", event => {
        event.preventDefault()
        field.focus()
      }, { signal: this.abortController.signal })
    })
    this.element.focus()
  }

  disconnect() {
    this.abortController.abort()
  }
}
