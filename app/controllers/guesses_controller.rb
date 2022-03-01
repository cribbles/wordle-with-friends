class GuessesController < ApplicationController
  before_action :require_login, only: :create
  before_action :require_turbo_frame_header

  def index
    player = Player.find(params[:player_id])
    render turbo_stream: turbo_stream.append(
      player,
      template: 'guesses/index',
      locals: {
        guesses: player.guesses,
        is_visible: player_guesses_visible?(player)
      }
    )
  end

  def show
    guess = Guess.find(params[:id])
    render :show, locals: {
      is_visible: guess_visible?(guess),
      guess: guess
    }
  end

  def new
    render :new, locals: {
      room: Room.find(room_id),
      guess: Guess.new
    }
  end

  def create
    @room = Room.find(room_id)
    guess = Guess.new(player_id: current_player_id, word: params[:word])
    @guess = guess.save ? Guess.new : guess
  end

  private

  def room_id
    params[:room_id]
  end

  def guess_visible?(guess)
    current_player_id == guess.player.id || guess.room.over?
  end

  def player_guesses_visible?(player)
    current_player_id == player.id || player.room.over?
  end
end
