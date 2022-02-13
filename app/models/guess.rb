class Guess < ApplicationRecord
  MAX_GUESSES ||= 6

  after_create_commit do
    broadcast_append_later_to player, target: player
  end

  belongs_to :player
  delegate :room, to: :player

  validates_associated :player, message: "Too many guesses"
  validates :word, inclusion: {
    in: Rails.cache.read(:guesses),
    message: "Not in word list"
  }

  def ==(word)
    self.word == word
  end

  def correct?
    evaluations.all?(&:correct)
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
