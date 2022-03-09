import { Controller } from "@hotwired/stimulus"

const WORD_CHAR_REGEX = /\w/

export default class extends Controller {
  click(event) {
    this.handleInput(event.target.dataset.key)
  }

  handleInput = (key) => {
    if (key === '↵') {
      document.querySelector('#room_form form').requestSubmit()
      return
    }

    const formInput = document.querySelector('input.form-control')
    if (WORD_CHAR_REGEX.test(key) && formInput.value.length < 5) {
      formInput.value += key
    } else if (key === '←') {
      formInput.value = formInput.value.slice(0, formInput.value.length - 1)
    }
  }
}