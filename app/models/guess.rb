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

  # Evalulates the guess against the room word, returning an array of symbols
  # representing whether each letter was correct, present, or absent.
  #
  # This has to be done in multiple passes, because we also want to reflect
  # the frequency of each letter within a word, prioritizing correct letters.
  #
  # EXAMPLE:
  # The room word is "PILLS"
  #
  # The guesses should be represented like:
  # "LLAMA" => "🟨🟨⬜⬜⬜"
  # "HALAL" => "⬜⬜🟩⬜🟨"
  # "ALLYL" => "⬜🟨🟩⬜⬜"
  # "LOLLY" => "⬜⬜🟩🟩⬜"
  def evaluations
    # Start by caching the count of each character within the room's word.
    #
    # This looks like:
    # ["L", "L", "A", "M", "A"]
    # #=> {"L"=>2, "A"=>2, "M"=>1}
    char_counts = room.word.chars.group_by(&:itself).transform_values(&:count)

    # We first iterate through the chars, marking any correct values and
    # keeping track of how many times they appear in the word compared to
    # the guess.
    #
    # If the char isn't correct, we return the original char. This gets
    # used in the next step.
    first_pass = ->(char, i) do
      if char == room.word[i]
        char_counts[char] -= 1
        :correct
      else
        char
      end
    end
  
    # We check the remaining chars for presence or absence. Crucially,
    # we don't mark a letter as present unless its count within the guess
    # exceeds its number of correct or present appearances so far.
    second_pass = ->(char, i) do
      if char == :correct
        char
      elsif room.word.include?(char) && char_counts[char].positive?
        char_counts[char] -= 1
        :present
      else
        :absent
      end
    end

    # Run the guess through both passes, returning the result.
    [first_pass, second_pass].reduce(self.word.chars) do |chars, block|
      chars.map.with_index(&block)
    end
  end
end
