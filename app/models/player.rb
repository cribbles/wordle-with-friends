class Player < ApplicationRecord
  extend AlphanumericallyIdentifiable

  MAX_GUESSES ||= 6

  after_create_commit do
    broadcast_append_later_to room,
                              :players,
                              target: :room_players
  end

  belongs_to :room
  has_many :guesses, dependent: :destroy
  validate :guesses_cannot_exceed_limit

  def can_guess?
    guesses.count < 6
  end

  def guess(word)
    Guess.create!(
      word: word,
      player: self
    )
  end

  def won?
    guesses.any?(&:correct?)
  end

  private

  def guesses_cannot_exceed_limit
    # TODO:
    # errors.add("Too many guesses") if guesses.count >= MAX_GUESSES
  end
end
