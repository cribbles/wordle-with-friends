require 'set'

class Player < ApplicationRecord
  extend AlphanumericallyIdentifiable

  MAX_GUESSES ||= 6

  belongs_to :room
  has_many :guesses, dependent: :destroy
  validates :name,
    length: { minimum: 1 },
    allow_nil: true,
    allow_blank: false
  validates :guesses, length: { maximum: MAX_GUESSES - 1 }

  after_create_commit do
    broadcast_append_later_to room,
                              :players,
                              target: :room_boards,
                              partial: 'rooms/board'
  end

  after_update_commit do
    broadcast_update_later_to self,
                              :name,
                              target: "name_player_#{id}",
                              partial: 'players/name'
  end

  def can_guess?
    guesses.count < MAX_GUESSES
  end

  def guess(word)
    Guess.create!(
      word: word,
      player: self
    )
  end

  def seen_letters
    guesses.each_with_object({}) do |guess, seen|
      guess.evaluations.each_with_index do |evaluation, i|
        letter = guess.word[i].to_sym
        seen[letter] = evaluation.to_s
      end
    end
  end

  def won?
    guesses.any?(&:correct?)
  end

  def broadcast_latest_state
    broadcast_update_later_to self, :guesses
  end
end
