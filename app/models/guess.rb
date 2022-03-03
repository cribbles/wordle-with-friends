class Guess < ApplicationRecord
  belongs_to :player
  delegate :room, to: :player
  default_scope { order(:id) }

  broadcasts_to ->(guess) { [guess.player, :guesses] },
    target: ->(guess) { guess.player }

  after_create_commit :handle_create
  after_destroy_commit { broadcast_remove_to player, :guesses }

  before_validation { word.downcase! }

  validates_associated :player,
    on: :create,
    message: "Too many guesses"
  validates :word, inclusion: {
    in: Rails.cache.read(:guesses),
    message: "Not in word list"
  }
  validates :word, length: {
    minimum: 5,
    maximum: 5,
    too_short: "Not enough letters",
    too_long: "Too many letters"
  }

  def ==(word)
    self.word == word
  end

  def correct?
    evaluations.all?(:correct)
  end

  def evaluations
    self.word.chars.map.with_index do |char, i|
      if char == room.word[i]
        :correct
      elsif room.word.include?(char)
        :present
      else
        :absent
      end
    end
  end

  private

  def handle_create
    if room.over?
      room.broadcast_latest_state
    else
      broadcast_append_later_to player, :guesses, target: player
    end
  end
end
