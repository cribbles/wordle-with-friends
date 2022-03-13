class GuessesController < ApplicationController
  before_action :require_login, only: :create
  before_action :require_turbo_frame_header

  def index
    player = Player.find(params[:player_id])
    render turbo_stream: turbo_stream.update(
      player,
      target: player,
      template: 'guesses/index',
      locals: {
        player: player,
        is_visible: player_guesses_visible?(player)
      }
    )
  end

  def show
    guess = Guess.find(params[:id])
    render :show, locals: {
      guess: guess,
      is_visible: guess_visible?(guess),
      refresh: false
    }
  end

  def new
    render :new, locals: {
      room: Room.find(room_id),
      guess: Guess.new,
      initial_render: true
    }
  end

  def create
    @room = Room.find(room_id)
    guess = Guess.new(player: current_player, word: params[:word])
    @guess = guess.save ? Guess.new : guess
    current_player.guesses.reload
  end

  private

  def room_id
    params[:room_id]
  end

  def guess_visible?(guess)
    guess.player == current_player || guess.room.over?
  end

  def player_guesses_visible?(player)
    player == current_player || player.room.over?
  end

  def require_login
    render status: :forbidden unless logged_in?
  end
end
