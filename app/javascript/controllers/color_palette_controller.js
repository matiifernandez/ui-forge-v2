import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["primaryColor", "secondaryColor", "preview", "paletteBtn"]

  static values = {
    palettes: { type: Array, default: [
      { name: "Ocean", primary: "#0077B6", secondary: "#90E0EF" },
      { name: "Sunset", primary: "#F77F00", secondary: "#FCBF49" },
      { name: "Forest", primary: "#2D6A4F", secondary: "#95D5B2" },
      { name: "Berry", primary: "#7B2CBF", secondary: "#C77DFF" },
      { name: "Slate", primary: "#334155", secondary: "#94A3B8" },
      { name: "Rose", primary: "#BE123C", secondary: "#FDA4AF" },
      { name: "Midnight", primary: "#1E1B4B", secondary: "#6366F1" },
      { name: "Earth", primary: "#78350F", secondary: "#D97706" }
    ]}
  }

  connect() {
    this.updatePreview()
  }

  selectPalette(event) {
    const btn = event.currentTarget
    const primary = btn.dataset.primary
    const secondary = btn.dataset.secondary

    this.primaryColorTarget.value = primary
    this.secondaryColorTarget.value = secondary

    // Update active state
    this.paletteBtnTargets.forEach(b => b.classList.remove("active"))
    btn.classList.add("active")

    this.updatePreview()
  }

  updatePreview() {
    const primary = this.primaryColorTarget.value
    const secondary = this.secondaryColorTarget.value

    this.previewTarget.innerHTML = `
      <div class="d-flex gap-2 align-items-center">
        <div style="width: 40px; height: 40px; background: ${primary}; border-radius: 8px; border: 2px solid #dee2e6;"></div>
        <div style="width: 40px; height: 40px; background: ${secondary}; border-radius: 8px; border: 2px solid #dee2e6;"></div>
        <div style="flex: 1; height: 40px; background: linear-gradient(90deg, ${primary} 0%, ${secondary} 100%); border-radius: 8px; border: 2px solid #dee2e6;"></div>
      </div>
    `
  }

  colorChanged() {
    // Remove active state from palette buttons when custom color is selected
    this.paletteBtnTargets.forEach(b => b.classList.remove("active"))
    this.updatePreview()
  }
}
