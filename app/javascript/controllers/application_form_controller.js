import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status", "appliedOn"]

  syncAppliedDate() {
    if (this.statusTarget.value === "wishlist" || this.appliedOnTarget.value) return

    const now = new Date()
    const localDate = new Date(now.getTime() - now.getTimezoneOffset() * 60_000)
    this.appliedOnTarget.value = localDate.toISOString().slice(0, 10)
  }
}
