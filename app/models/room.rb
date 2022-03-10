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
    Guess.where(player: players, word: word).any?
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
    %w{ dashboard form signup }.each &method(:refresh_partial)
    players.each(&:broadcast_latest_state)
  end

  private

  def clear_guesses
    Guess.where(player: players).destroy_all
  end

  def reset_word
    self.word = Room.random_word
    save
  end

  def refresh_partial(partial)
    broadcast_update_later_to(
      self,
      target: "room_#{partial}",
      partial: "rooms/#{partial}",
      locals: { room: self, initial_render: false }
    )
  end
end
