import { Controller } from "@hotwired/stimulus"

const EVALUATION_EMOJIS = {
  absent:  '⬜',
  correct: '🟩',
  present: '🟨',
}

const childrenByClass = (parentEl, className) => Array.from(
  parentEl.getElementsByClassName(className)
)

const getPlayerName = (board) => {
  const [{ textContent }] = childrenByClass(board, 'player-name')
  return textContent.trim()
}

const toEmoji = (tile) => EVALUATION_EMOJIS[tile.dataset.state]

const getFormattedTiles = (row) => {
  const tiles = childrenByClass(row, 'tile')
  return tiles.map(toEmoji).join('')
}

const getFormattedRows = (board) => {
  const nonEmptyRows = childrenByClass(board, 'non-empty')
  return nonEmptyRows.map(getFormattedTiles).join('\n')
}

const getFormattedBoard = (board) => [
  getPlayerName(board),
  getFormattedRows(board),
].join('\n')

const getFormattedBoards = (boards) =>
  boards.map(getFormattedBoard).join('\n\n')

const copyFormattedBoardsToClipboard = () => {
  const boards = childrenByClass(document, 'board')
  const formattedBoards = getFormattedBoards(boards)
  navigator.clipboard.writeText(formattedBoards)
}

const notifyUserOfCopyEvent = () => {
  const notification = document.createElement('p')
  notification.textContent = 'Copied to clipboard :)'
  document.getElementById('end-banner').after(notification)
}

export default class extends Controller {
  click() {
    copyFormattedBoardsToClipboard()
    notifyUserOfCopyEvent()
  }
}