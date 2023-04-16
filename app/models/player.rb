require 'set'

class Player < ApplicationRecord
  extend AlphanumericallyIdentifiable

  class << self
    def attrs_from_session_token(token)
      token.split(':') => [id, password]
      { id:, password: }
    end

    private

    def generate_attributes
      super.merge(password: random_id)
    end
  end

  MAX_GUESSES ||= 6

  belongs_to :room
  has_many :guesses, dependent: :destroy
  validates :name,
    length: { minimum: 1 },
    allow_nil: true,
    allow_blank: false
  validates :guesses, length: { maximum: MAX_GUESSES - 1 }

  after_create_commit do
    broadcast_append_later_to room,
                              :players,
                              target: :room_boards,
                              partial: 'rooms/board'
  end

  after_update_commit do
    broadcast_update_later_to self,
                              :name,
                              target: "name_player_#{id}",
                              partial: 'players/name'
  end

  def can_guess?
    guesses.count < MAX_GUESSES
  end

  def name
    return super if new_record?
    self[:name] || "Player #{room.players.find_index(self) + 1}"
  end

  def unnamed?
    self[:name].blank?
  end

  def guess(word)
    Guess.create!(
      word: word,
      player: self
    )
  end

  def seen_letters
    guesses.each_with_object({}) do |guess, seen|
      guess.evaluations.each_with_index do |evaluation, i|
        letter = guess.word[i].to_sym
        seen[letter] = evaluation.to_s
      end
    end
  end

  def session_token
    [id, password].join(':')
  end

  def won?
    guesses.any?(&:correct?)
  end

  def broadcast_latest_state
    broadcast_update_later_to self, :guesses
  end
end
