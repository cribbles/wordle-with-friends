class Guess < ApplicationRecord
  MAX_GUESSES ||= 6

  belongs_to :player
  delegate :room, to: :player

  after_create_commit do
    broadcast_append_later_to player,
                              target: player,
                              locals: { room: room }
    broadcast_update_later_to room,
                              target: :room_dashboard,
                              partial: 'rooms/dashboard',
                              locals: { room: room }
    if room.over?
      room.stream_latest_state
    end
  end

  after_destroy_commit do
    broadcast_remove_to player, target: self
  end

  before_validation { word.downcase! }

  validate { errors[:base] << "Wordle already solved" if room.won? }
  validates_associated :player, message: "Too many guesses"
  validates :word, inclusion: {
    in: Rails.cache.read(:guesses),
    message: "Not in word list"
  }

  def ==(word)
    self.word == word
  end

  def correct?
    evaluations.all?(:correct)
  end

  def evaluations
    self.word.chars.map.with_index do |char, i|
      if char == room.word[i]
        :correct
      elsif room.word.include?(char)
        :present
      else
        :absent
      end
    end
  end

  def stream_latest_state
    broadcast_replace_later_to player,
                               target: self,
                               locals: { room: room, guess: self }
  end
end
