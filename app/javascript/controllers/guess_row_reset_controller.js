import { Controller } from "@hotwired/stimulus"

const getTbdTiles = () => Array.from(
  document.querySelectorAll('.tile[data-state="tbd"]')
)

const resetTile = (tile) => {
  tile.dataset.state = 'empty'
  tile.textContent = ''
}

const clearTbdTiles = () => getTbdTiles().forEach(resetTile)

export default class extends Controller {
  initialize = clearTbdTiles
}