import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { minHeight: { type: Number, default: 40 } }

  connect() {
    this.boundMessageHandler = this.handleMessage.bind(this)
    window.addEventListener('message', this.boundMessageHandler)
    this.element.addEventListener('load', () => this.fallbackResize())
  }

  disconnect() {
    window.removeEventListener('message', this.boundMessageHandler)
  }

  handleMessage(event) {
    if (event.data?.type !== 'iframeResize') return
    if (event.source !== this.element.contentWindow) return

    const height = Math.max(event.data.height, this.minHeightValue)
    this.element.style.height = `${height}px`
  }

  fallbackResize() {
    setTimeout(() => {
      try {
        const doc = this.element.contentDocument || this.element.contentWindow?.document
        if (!doc?.body) return

        const wrapper = doc.getElementById('component-wrapper')
        if (wrapper) {
          const height = Math.max(wrapper.offsetHeight, this.minHeightValue)
          this.element.style.height = `${height}px`
        }
      } catch (e) {
        // Cross-origin or access error - ignore
      }
    }, 200)
  }
}
