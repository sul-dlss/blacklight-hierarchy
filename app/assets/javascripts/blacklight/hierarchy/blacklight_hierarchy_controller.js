import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "list" ]
  connect() {
    this.element.classList.add("twiddle")
  }

  toggle() {
    this.element.classList.toggle("twiddle-open")
  }
}
