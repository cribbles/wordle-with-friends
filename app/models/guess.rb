class Guess < ApplicationRecord
  after_create_commit { broadcast_prepend_later_to 'guesses' }

  COLORS = {
    # right letter, right place
    green: 'G',
    # right letter, wrong place
    yellow: 'Y',
    # wrong letter
    gray: 'X'
  }

  belongs_to :player
  delegate :room, to: :player

  validates :word, inclusion: { in: Rails.cache.read(:guesses) }

  def ==(word)
    self.word == word
  end

  def correct?
    self.to_s == COLORS[:green].repeat(5)
  end

  def to_s
    self.word.chars.map.with_index do |char, i|
      if char == room.word[i]
        COLORS[:green]
      elsif room.word.include?(char)
        COLORS[:yellow]
      else
        COLORS[:gray]
      end
    end.join
  end
end
