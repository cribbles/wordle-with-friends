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

  def full?
    players.many?
  end

  def won?
    !!winner
  end

  def winner
    players.find(&:won?)
  end

  def reset!
    clear_guesses
    reset_word
  end

  private

  def clear_guesses
    Guess.where(player: players).delete_all
  end

  def reset_word
    self.word = Room.random_word
    save
  end
end
