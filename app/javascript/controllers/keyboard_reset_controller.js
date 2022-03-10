import { Controller } from "@hotwired/stimulus"

const KEY_STATES = [
  'absent',
  'correct',
  'present'
]

const getKeys = () => Array.from(
  document
    .getElementById('keyboard')
    .getElementsByTagName('button')
)

const clearState = (key) => (state) => key.classList.remove(state)

const clearKey = (key) => KEY_STATES.forEach(clearState(key))

const clearKeyboard = () => getKeys().forEach(clearKey)

export default class extends Controller {
  initialize = clearKeyboard
}