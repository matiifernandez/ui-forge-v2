// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

// Override Turbo's confirm method to use SweetAlert2 with dark theme
// Swal is loaded globally via script tag in application.html.erb
Turbo.config.forms.confirm = (message, _element) => {
  return Swal.fire({
    title: "Are you sure?",
    text: message,
    icon: "warning",
    showCancelButton: true,
    confirmButtonColor: "#f85149",
    cancelButtonColor: "#30363d",
    confirmButtonText: "Yes, delete it!",
    cancelButtonText: "Cancel",
    background: "#161b22",
    color: "#e6edf3",
    customClass: {
      popup: 'dark-swal-popup',
      confirmButton: 'dark-swal-confirm',
      cancelButton: 'dark-swal-cancel'
    }
  }).then((result) => result.isConfirmed)
}
