import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "list" ]
  connect() {
    this.element.classList.add("twiddle")

    // If a child facet-value is selected, then expand the node
    if (this.isChildSelected()) {
      this.element.classList.add('twiddle-open')
      this.element.querySelectorAll(':scope > .collapse')
        .forEach((collapsable) => collapsable.classList.add('show'))
    }
  }

  isChildSelected() {
    return this.element.querySelector('span.selected')
  }

  toggle() {
    this.element.classList.toggle("twiddle-open")
  }
}
