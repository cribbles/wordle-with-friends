import { Controller } from "@hotwired/stimulus"

const ENTER = 13;
const ANY_NON_WHITESPACE_CHAR_REGEXP = /\S/

export default class extends Controller {
  static targets = ["name", "input"]

  click() {
    this.nameTarget.textContent = "";
    this.nameTarget.setAttribute("contenteditable", "true")
    this.nameTarget.focus()
  }

  blur() {
    this.nameTarget.removeAttribute("contenteditable")
    this.save()
  }

  keydown(event) {
    if (event.keyCode == ENTER) {
      event.preventDefault()
      this.nameTarget.removeAttribute("contenteditable")
      this.save()
    }
  }

  save = () => {
    if (this.inputTarget.value === this.nameTarget.textContent) {
      return
    }
    if (!ANY_NON_WHITESPACE_CHAR_REGEXP.test(this.nameTarget.textContent)) {
      this.nameTarget.textContent = this.inputTarget.value
      return
    }
    this.inputTarget.value = this.nameTarget.textContent
    this.element.querySelector("form").requestSubmit()
  }
}