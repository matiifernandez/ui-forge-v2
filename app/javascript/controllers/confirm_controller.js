import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: { type: String, default: "Are you sure?" },
    text: { type: String, default: "This action cannot be undone." },
    confirmText: { type: String, default: "Yes, delete it!" },
    cancelText: { type: String, default: "Cancel" }
  }

  async confirm(event) {
    event.preventDefault()
    event.stopPropagation()

    const result = await Swal.fire({
      title: this.titleValue,
      text: this.textValue,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc3545",
      cancelButtonColor: "#6c757d",
      confirmButtonText: this.confirmTextValue,
      cancelButtonText: this.cancelTextValue
    })

    if (result.isConfirmed) {
      // Proceed with the action
      const link = event.currentTarget
      const method = link.dataset.turboMethod || "get"

      if (method === "delete") {
        // Create and submit a form for DELETE request
        const form = document.createElement("form")
        form.method = "POST"
        form.action = link.href

        const methodInput = document.createElement("input")
        methodInput.type = "hidden"
        methodInput.name = "_method"
        methodInput.value = "delete"
        form.appendChild(methodInput)

        const csrfToken = document.querySelector("meta[name='csrf-token']").content
        const csrfInput = document.createElement("input")
        csrfInput.type = "hidden"
        csrfInput.name = "authenticity_token"
        csrfInput.value = csrfToken
        form.appendChild(csrfInput)

        document.body.appendChild(form)
        form.requestSubmit()
      } else {
        window.location.href = link.href
      }
    }
  }
}
