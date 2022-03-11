import { Controller } from "@hotwired/stimulus"

const KEY_SYMBOLS = {
  Enter: '↵',
  Backspace: '←'
}
const TILES_STATE = { empty: [], tbd: [] };
const WORD_CHAR_REGEX = /^\w$/

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
  tile.textContent = key
}

const resetTile = (tile) => {
  tile.dataset.state = 'empty'
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
    const {
      empty: [firstEmptyTile],
      tbd: tbdTiles
    } = getPlayerTiles(this.playerIdValue)
    const formInput = document.getElementById('guess')

    if (key === KEY_SYMBOLS.Enter && !!formInput.value) {
      document.querySelector('#room_form form').requestSubmit()
      tbdTiles.forEach(resetTile);
      formInput.value = ''
      return
    }

    if (WORD_CHAR_REGEX.test(key) && !!firstEmptyTile) {
      formInput.value += key
      setTile(firstEmptyTile, key)
    } else if (key === KEY_SYMBOLS.Backspace && tbdTiles.length) {
      formInput.value = formInput.value.slice(0, formInput.value.length - 1)
      const lastTbdTile = tbdTiles[tbdTiles.length - 1]
      resetTile(lastTbdTile)
    }
  }
}