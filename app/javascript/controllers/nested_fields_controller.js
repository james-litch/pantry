import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "item", "template", "add"]
  static values = { placeholder: String, label: String }

  connect() {
    this.renumber()
  }

  add() {
    // Numeric keys work with Rails' nested strong parameters. Include a counter
    // so rapid additions within the same millisecond still have unique names.
    this.sequence = (this.sequence || 0) + 1
    const key = `${Date.now()}${this.sequence}`
    const html = this.templateTarget.innerHTML.replaceAll(this.placeholderValue, key)
    this.listTarget.insertAdjacentHTML("beforeend", html)
    this.renumber()
    this.listTarget.lastElementChild.querySelector("input, textarea").focus()
  }

  remove(event) {
    const item = event.currentTarget.closest('[data-nested-fields-target="item"]')
    const next = item.nextElementSibling || item.previousElementSibling
    item.remove()
    this.renumber()
    const control = next?.querySelector("input, textarea, button") || this.addTarget
    control.focus()
  }

  renumber() {
    Array.from(this.listTarget.children).forEach((item, index) => {
      item.querySelector("[data-row-label]").textContent = `${this.labelValue} ${index + 1}`
    })
  }
}
