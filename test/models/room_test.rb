require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  def setup
    @room = rooms(:one)
    @valid_word = 'allyl'
    Rails.cache.write(:guesses, [@valid_word, @room.word])
  end

  test '#empty? is true if no players are in the room' do
    assert_not @room.empty?
    @room.players.destroy_all
    assert @room.empty?
  end

  test '#full? is true if the room has multiple players' do
    @room.players.destroy_all
    assert_not @room.full?
    @room.players.create!(id: 'foo', password: '12345')
    assert_not @room.full?
    @room.players.create!(id: 'bar', password: '12345')
    assert @room.full?
  end

  test '#won? is true if any player has a correct guess' do
    assert_not @room.won?
    player = players(:one)
    player.guesses.destroy_all
    player.guesses.create!(word: @valid_word)
    assert_not @room.won?
    player.guesses.create!(word: @room.word)
    assert @room.won?
  end

  test '#lost? is true if all players have exhausted their guesses' do
    @room.players.each { |p| p.guesses.destroy_all }
    @room.players.each do |player|
      assert_not @room.lost?
      Player::MAX_GUESSES.times { player.guesses.create!(word: 'ALLYL') }
    end
    assert @room.lost?
  end
end
