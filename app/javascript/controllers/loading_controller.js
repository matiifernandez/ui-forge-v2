import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "loading", "submitBtn"]

  connect() {
    // Listen for turbo events to handle responses
    this.element.addEventListener('turbo:submit-start', this.showLoading.bind(this))
    this.element.addEventListener('turbo:submit-end', this.handleResponse.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('turbo:submit-start', this.showLoading.bind(this))
    this.element.removeEventListener('turbo:submit-end', this.handleResponse.bind(this))
  }

  submit(event) {
    this.showLoading()
  }

  showLoading() {
    if (this.hasFormTarget && this.hasLoadingTarget) {
      this.formTarget.classList.add("d-none")
      this.loadingTarget.classList.remove("d-none")
    }
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.disabled = true
    }
  }

  handleResponse(event) {
    // If there was an error (422), show the form again
    if (!event.detail.success) {
      this.hideLoading()
    }
  }

  hideLoading() {
    if (this.hasFormTarget && this.hasLoadingTarget) {
      this.formTarget.classList.remove("d-none")
      this.loadingTarget.classList.add("d-none")
    }
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.disabled = false
    }
  }
}
