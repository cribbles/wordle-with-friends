require 'set'

class Player < ApplicationRecord
  extend AlphanumericallyIdentifiable

  MAX_GUESSES ||= 6

  belongs_to :room
  has_many :guesses, dependent: :destroy

  after_create_commit do
    broadcast_append_later_to room, :boards, target: :room_boards
  end

  validate :guesses_cannot_exceed_limit

  def can_guess?
    guesses.count < 6
  end

  def guess(word)
    Guess.create!(
      word: word,
      player: self
    )
  end

  def seen_letters
    seen = Hash.new { |hash, key| hash[key] = Set.new }
    guesses.each do |guess|
      guess.evaluations.each_with_index do |evaluation, i|
        seen[evaluation] << guess.word[i]
      end
    end
    seen.transform_values { |set| set.to_a.map(&:upcase).sort }
  end

  def won?
    guesses.any?(&:correct?)
  end

  private

  def guesses_cannot_exceed_limit
    # TODO:
    # errors.add("Too many guesses") if guesses.count >= MAX_GUESSES
  end
end
