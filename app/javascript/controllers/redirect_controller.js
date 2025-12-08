import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = { url: String }

  connect() {
    if (this.urlValue) {
      Turbo.visit(this.urlValue)
    }
  }
}
