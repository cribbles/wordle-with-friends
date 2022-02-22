class PlayersController < ApplicationController
  def create
    player = Player.generate!(room_id: room_id)
    session[room_id] = player.id
    respond_to do |format|
      format.html { redirect_to room_path(room_id) }
      format.turbo_stream do
        room = Room.find(room_id)
        render turbo_stream: [
          replace_room_dashboard(room),
          destroy_room_signup,
          append_room_form(room)
        ]
      end
    end
  end

  private

  def room_id
    params[:room_id]
  end

  def replace_room_dashboard(room)
    turbo_stream.replace(
      :room_dashboard,
      partial: 'rooms/dashboard',
      locals: { room: room }
    )
  end

  def destroy_room_signup
    turbo_stream.remove(:room_signup)
  end

  def append_room_form(room)
    turbo_stream.append(
      :room_form,
      partial: 'rooms/form',
      locals: {
        room: room,
        guess: Guess.new
      }
    )
  end
end
