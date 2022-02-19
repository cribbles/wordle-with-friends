class PlayersController < ApplicationController
  def create
    room_id = params[:room_id]
    player = Player.generate!(room_id: room_id)
    session[room_id] = player.id
    respond_to do |format|
      format.html { redirect_to room_path(room_id) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          :room_form,
          partial: 'rooms/form',
          locals: {
            room: Room.find(room_id),
            guess: Guess.new
          }
        )
      end
    end
  end
end
