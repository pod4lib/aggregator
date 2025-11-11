import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter"
export default class extends Controller {
  static targets = ['autosubmit']

  submit() {
    this.element.requestSubmit()
  }

  clear() {
    this.element.querySelectorAll('input.form-control').forEach((input) => {
      input.value = null
    })

    this.submit();
  }
}
