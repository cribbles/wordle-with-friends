class Room < ApplicationRecord
  extend AlphanumericallyIdentifiable

  has_many :players, dependent: :destroy
  has_many :guesses, through: :players

  class << self
    def random_word
      Rails.cache.read(:words).sample
    end

    private

    def generate_attributes
      super.merge(word: random_word)
    end
  end

  def empty?
    players.none?
  end

  def full?
    players.many?
  end

  def won?
    Guess.where(
      player: players.map(&:id),
      word: word
    ).any?
  end

  def lost?
    players.none?(&:can_guess?)
  end

  def over?
    won? || lost?
  end

  def winner
    players.find(&:won?)
  end

  def reset!
    clear_guesses
    reset_word
    broadcast_latest_state
  end

  def broadcast_latest_state
    ['dashboard', 'form', 'signup'].each do |partial|
      broadcast_replace_later_to self,
                                 target: "room_#{partial}",
                                 partial: "rooms/#{partial}",
                                 locals: { room: self }
    end

    # TODO: This requires us to go through each guess frame, which is
    # very inefficient and causes a noticably slow repaint.
    # We should instead refresh the boards partial with a Guess#index
    # frame tailored to each player.
    guesses.each { |guess| guess.broadcast_replace_later_to player, :guesses }
  end

  private

  def clear_guesses
    Guess.where(player: players).destroy_all
  end

  def reset_word
    self.word = Room.random_word
    save
  end
end
