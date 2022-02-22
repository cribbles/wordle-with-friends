class GuessesController < ApplicationController
  def show
    if request.headers["turbo-frame"]
      guess = Guess.find(params[:id])
      render :show, locals: {
        is_visible: is_visible?(guess),
        guess: guess
      }
    else
      render status: :forbidden
    end
  end

  def create
    render status: :forbidden unless current_player_id

    room = Room.find(room_id)
    guess = Guess.new(player_id: current_player_id, word: params[:word])

    respond_to do |format|
      if guess.save
        format.html { redirect_to room_path(room_id) }
        format.turbo_stream do
          render turbo_stream: [
            replace_room_dashboard(room),
            replace_room_form(room, Guess.new)
          ]
        end
      else
        format.turbo_stream do
          render turbo_stream: [
            replace_room_dashboard(room),
            replace_room_form(room, guess)
          ]
        end
      end
    end
  end

  private

  def room_id
    params[:room_id]
  end

  def is_visible?(guess)
    current_player_id == guess.player.id || guess.room.over?
  end

  def replace_room_dashboard(room)
    turbo_stream.replace(
      :room_dashboard,
      partial: 'rooms/dashboard',
      locals: { room: room }
    )
  end

  def replace_room_form(room, guess)
    turbo_stream.replace(
      :room_form,
      partial: 'rooms/form',
      locals: {
        room: room,
        guess: guess
      }
    )
  end
end
