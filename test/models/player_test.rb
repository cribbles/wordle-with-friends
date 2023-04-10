require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  def setup
    @room = rooms(:one)
    @valid_word = 'allyl'
    Rails.cache.write(:guesses, [@valid_word, @room.word])
    @player = Player.create!(id: "foo", room: @room, password: '12345')
  end

  test '#can_guess? is true unless player has max guesses' do
    assert @player.can_guess?
    Player::MAX_GUESSES.times { @player.guesses.create!(word: @valid_word) }
    assert_not @player.can_guess?
  end

  test '#unnamed? is true unless name is set' do
    assert @player.unnamed?
    @player.update(name: 'Player 1')
    assert_not @player.unnamed?
  end

  test '#guess creates a new guess for the player' do
    assert_difference 'Guess.count', 1 do
      @player.guess(@valid_word)
    end
  end

  test '#won? is true if player has a correct guess' do
    assert_not @player.won?
    @player.guesses.create!(word: @room.word)
    assert @player.won?
  end

  test '#won? is false if player has no correct guesses' do
    assert_not @player.won?
    @player.guesses.create!(word: @valid_word)
    assert_not @player.won?
  end
end
