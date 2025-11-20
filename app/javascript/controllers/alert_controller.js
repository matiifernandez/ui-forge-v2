import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Define a value to control the duration in milliseconds (default to 3000ms = 3 seconds)
  static values = { duration: { type: Number, default: 3000 } }

  connect() {
    // Start the timer when the element (the error box) is connected to the DOM
    this.startTimer();
  }

  startTimer() {
    this.timer = setTimeout(() => {
      // After the duration, remove the element entirely from the DOM
      this.element.remove();
    }, this.durationValue);
  }

  // Good practice: clear the timer if the element is disconnected before the timeout
  disconnect() {
    clearTimeout(this.timer);
  }
}
