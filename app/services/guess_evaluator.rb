class GuessEvaluator
  def initialize(guess_word, room_word)
    @guess_word = guess_word
    @room_word = room_word
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
    first_pass_chars = first_pass
    second_pass_chars = second_pass(first_pass_chars)

    second_pass_chars
  end

  private

  attr_reader :guess_word, :room_word

  def char_counts
    @char_counts ||= build_char_counts
  end

  # Caches the count of each character within the room's word.
  #
  # This looks like:
  # ["L", "L", "A", "M", "A"]
  # #=> {"L"=>2, "A"=>2, "M"=>1}
  def build_char_counts
    room_word.chars.group_by(&:itself).transform_values(&:count)
  end

  # We first iterate through the chars, marking any correct values and
  # keeping track of how many times they appear in the word compared to
  # the guess.
  #
  # If the char isn't correct, we return the original char. This gets
  # used in the next step.
  def first_pass
    guess_word.chars.map.with_index do |char, i|
      if char == room_word[i]
        char_counts[char] -= 1
        :correct
      else
        char
      end
    end
  end

  # We check the remaining chars for presence or absence. Crucially,
  # we don't mark a letter as present unless its count within the guess
  # exceeds its number of correct or present appearances so far.
  def second_pass(first_pass_chars)
    first_pass_chars.map do |char|
      if char == :correct
        char
      elsif room_word.include?(char) && char_counts[char].positive?
        char_counts[char] -= 1
        :present
      else
        :absent
      end
    end
  end
end
