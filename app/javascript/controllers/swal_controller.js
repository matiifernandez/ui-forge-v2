import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: { type: String, default: "info" },
    message: String,
    title: String,
    toast: { type: Boolean, default: true }
  }

  connect() {
    this.showAlert()
  }

  showAlert() {
    const iconMap = {
      notice: "success",
      info: "info",
      alert: "warning",
      error: "error",
      success: "success",
      warning: "warning"
    }

    const icon = iconMap[this.typeValue] || "info"

    if (this.toastValue) {
      // Toast notification (non-blocking)
      const Toast = Swal.mixin({
        toast: true,
        position: "top-end",
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
          toast.onmouseenter = Swal.stopTimer
          toast.onmouseleave = Swal.resumeTimer
        }
      })

      Toast.fire({
        icon: icon,
        title: this.messageValue
      })
    } else {
      // Modal alert
      Swal.fire({
        icon: icon,
        title: this.titleValue || "",
        text: this.messageValue,
        confirmButtonColor: "#0d6efd"
      })
    }

    // Remove the element after showing
    this.element.remove()
  }
}
