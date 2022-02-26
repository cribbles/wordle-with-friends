class Guess < ApplicationRecord
  MAX_GUESSES ||= 6

  belongs_to :player
  delegate :room, to: :player

  broadcasts_to ->(guess) { [guess.player, :guesses] },
    target: ->(guess) { guess.player }

  after_create_commit { room.broadcast_latest_state if room.over? }

  before_validation { word.downcase! }

  validate { errors[:base] << "Wordle already solved" if room.won? }
  validates_associated :player, message: "Too many guesses"
  validates :word, inclusion: {
    in: Rails.cache.read(:guesses),
    message: "Not in word list"
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
end
