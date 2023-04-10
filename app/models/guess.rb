class Guess < ApplicationRecord
  belongs_to :player
  delegate :room, to: :player
  default_scope { order(:id) }

  after_create_commit -> {
    if room.over?
      room.broadcast_latest_state
    else
      broadcast_append_later_to player, :guesses, target: player
    end
  }

  before_validation { word&.downcase! }

  validates_associated :player,
    on: :create,
    message: "Too many guesses"

  validates :word, inclusion: {
    in: ->(_) { Rails.cache.read(:guesses) },
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
    GuessEvaluator.new(self.word, room.word).evaluations
  end
end
