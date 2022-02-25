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
    stream_latest_state
  end

  def stream_latest_state
    ['dashboard', 'form', 'signup'].each do |partial|
      broadcast_replace_later_to self,
                                 target: "room_#{partial}",
                                 partial: "rooms/#{partial}",
                                 locals: { room: self }
    end
    guesses.each(&:stream_latest_state)
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
