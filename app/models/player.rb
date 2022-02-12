class Player < ApplicationRecord
  belongs_to :room
  has_many :guesses, dependent: :destroy

  def guess(word)
    Guess.create!(
      word: word,
      player: self
    )
  end

  def won?
    guesses.any?(&:correct?)
  end
end
