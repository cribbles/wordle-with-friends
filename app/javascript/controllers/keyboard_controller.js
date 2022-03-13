import { Controller } from "@hotwired/stimulus"

const KEY_SYMBOLS = {
  Enter: '↵',
  Backspace: '←'
}
const TILES_STATE = { empty: [], tbd: [] }
const WORD_CHAR_REGEX = /^\w$/

const getFormInputElement = () =>
  document.getElementById('guess')

const submitForm = () =>
  document.querySelector('#room_form form').requestSubmit()

const getFirstEmptyPlayerRow = (playerId) =>
  document
    .getElementById(`empty_rows_player_${playerId}`)
    .querySelector('.row:first-child')

const getRowTiles = (row) =>
  Array.from(row.children).reduce((tiles, tile) => ({
    ...tiles,
    [tile.dataset.state]: [...(tiles[tile.dataset.state] || []), tile]
  }), TILES_STATE)

const getPlayerTiles = (player) => getRowTiles(getFirstEmptyPlayerRow(player))

const setTile = (tile, key) => {
  tile.dataset.state = 'tbd'
  tile.dataset.animation = 'pop'
  tile.textContent = key
}

const resetTile = (tile) => {
  tile.dataset.state = 'empty'
  tile.dataset.animation = 'idle'
  tile.textContent = ''
}

export default class extends Controller {
  static values = {
    playerId: String
  }

  connect() {
    document.addEventListener('keydown', this.handleKeyDown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeyDown)
  }

  click(event) {
    this.handleInput(event.target.dataset.key)
  }

  handleKeyDown = (event) => {
    if (document.activeElement.contentEditable === 'true') {
      // player is changing their name, ignore
      return
    }
    this.handleInput(KEY_SYMBOLS[event.key] || event.key)
  }

  handleInput = (key) => {
    const formInputEl = getFormInputElement()
    if (!this.canGuess(formInputEl)) return

    const { value: currentGuess } = formInputEl

    if (WORD_CHAR_REGEX.test(key) && currentGuess.length < 5) {
      this.addToGuess(formInputEl, key)
    } else if (currentGuess.length > 0) {
      if (key === KEY_SYMBOLS.Enter) {
        this.submitGuess(formInputEl)
      } else if (key === KEY_SYMBOLS.Backspace) {
        this.removeFromGuess(formInputEl)
      }
    }
  }

  playerTiles = () => getPlayerTiles(this.playerIdValue)

  canGuess = (formInputEl) =>
    !!formInputEl &&
    document.getElementById(`player_${this.playerIdValue}`).children.length < 6

  addToGuess = (formInputEl, letter) => {
    formInputEl.value += letter
    const [firstEmptyTile] = this.playerTiles().empty
    setTile(firstEmptyTile, letter)
  }

  removeFromGuess = (formInputEl) => {
    const newGuess = formInputEl.value.slice(0, formInputEl.value.length - 1)
    formInputEl.value = newGuess
    const tbdTiles = this.playerTiles().tbd
    const lastTbdTile = tbdTiles[tbdTiles.length - 1]
    resetTile(lastTbdTile)
  }

  submitGuess = (formInputEl) => {
    submitForm()
    formInputEl.value = ''
    this.playerTiles().tbd.forEach(resetTile)
  }
}