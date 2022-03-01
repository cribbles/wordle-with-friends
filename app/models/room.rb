class Room < ApplicationRecord
  extend AlphanumericallyIdentifiable

  has_many :players, dependent: :destroy
  has_many :guesses, through: :players

  class << self
    def random_word
      'chubs'
      # Rails.cache.read(:words).sample
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
    refresh_partials %w{ dashboard form signup }

    # TODO
    guesses.each { |g| g.broadcast_update_later_to g.player, :guesses }
  end

  private

  def clear_guesses
    Guess.where(player: players).destroy_all
  end

  def reset_word
    self.word = Room.random_word
    save
  end

  def refresh_partials(partials)
    partials.each do |partial|
      broadcast_update_later_to self,
                           target: "room_#{partial}",
                           partial: "rooms/#{partial}"
    end
  end
end
