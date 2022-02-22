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
    !!winner
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
    stream_changes
  end

  private

  def clear_guesses
    Guess.where(player: players).destroy_all
  end

  def reset_word
    self.word = Room.random_word
    save
  end

  def stream_changes
    # broadcast_replace_to(
    #   self,
    #   target: :room_dashboard,
    #   partial: 'rooms/dashboard'
    #   # inline: 'hello'
    # )

    # broadcast_replace_to(
    #   self,
    #   target: :room_signup,
    #   partial: 'rooms/signup',
    #   locals: { room: self }
    # )

    broadcast_replace_to(
      self,
      target: :room_form,
      partial: 'rooms/form',
      locals: { room: self, guess: Guess.new }
    )
  end
end
