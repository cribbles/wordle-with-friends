require "test_helper"

class GuessTest < ActiveSupport::TestCase
  def setup
    @player = players(:one)
    Rails.cache.write(:guesses, %w[apple mango grape lemon berry])
    @guess = Guess.new(player: @player, word: "apple")
  end

  teardown do
    Rails.cache.clear
  end

  test "guess in word list is valid" do
    assert @guess.valid?
  end

  test "guess not in word list is invalid" do
    @guess.word = "chubs"
    refute @guess.valid?
  end

  test "invalid without player" do
    @guess.player = nil
    refute @guess.valid?
  end

  test "invalid without word" do
    @guess.word = nil
    refute @guess.valid?
  end

  test "#word downcases before validation" do
    @guess.word = "ApPlE"
    @guess.validate
    assert_equal "apple", @guess.word
  end

  test "equality method works with strings" do
    assert_equal @guess, "apple"
    refute_equal @guess, "mango"
  end

  test "#correct? method evaluates against room word" do
    room_word = "apple"
    @player.room.word = room_word
    assert @guess.correct?

    @player.room.word = "mango"
    refute @guess.correct?
  end

  test "#evaluations returns the correct evaluations" do
    room_word = "pills"
    @player.room.word = room_word

    @guess.word = "llama"
    assert_equal %i[present present absent absent absent], @guess.evaluations

    @guess.word = "halal"
    assert_equal %i[absent absent correct absent present], @guess.evaluations

    @guess.word = "allyl"
    assert_equal %i[absent present correct absent absent], @guess.evaluations

    @guess.word = "lolly"
    assert_equal %i[absent absent correct correct absent], @guess.evaluations
  end
end
