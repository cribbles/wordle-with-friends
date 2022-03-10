import { Controller } from "@hotwired/stimulus"

const getKeys = () => Array.from(
  document
    .getElementById('keyboard')
    .getElementsByTagName('button')
)

const resetKeyboard = () => getKeys().forEach((key) => key.className = '')

export default class extends Controller {
  initialize = resetKeyboard
}