import { Controller } from "@hotwired/stimulus"

const TIMEOUT_INTERVALS = {
  refresh: 125,
  reveal: 250,
}

const getTiles = (el) => Array.from(
  el.getElementsByClassName('tile')
)

const setTileAnimationTimeouts = (tiles, interval) => {
  tiles.flatMap((tile, i) => {
    const animations = ['in', 'out'].map((dir) =>
      () => tile.dataset.animation = `flip-${dir}`
    )
    return animations.map((animation, j) => window.setTimeout(
      animation,
      interval * (i + j)
    ))
  })
}

export default class extends Controller {
  static values = {
    origin: String
  }
  static targets = ['row']

  connect() {
    const tiles = getTiles(this.rowTarget)
    const interval = TIMEOUT_INTERVALS[this.originValue]
    this.timeouts = setTileAnimationTimeouts(tiles, interval)
  }

  disconnect() {
    this.timeouts.forEach(window.clearTimeout)
  }
}