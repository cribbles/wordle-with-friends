class Guess < ApplicationRecord
  after_create_commit { broadcast_append_later_to :guesses }

  EVALUATION_LETTERS = {
    correct: 'C',
    present: 'P',
    absent: 'A'
  }

  belongs_to :player
  delegate :room, to: :player

  validates :word, inclusion: { in: Rails.cache.read(:guesses) }

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
