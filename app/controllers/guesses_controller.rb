class GuessesController < ApplicationController
  include Playable

  def create
    room_id = params[:room_id]
    render status: :forbidden unless player_id = session[room_id]

    room = Room.find(room_id)
    guess = Guess.new(player_id: player_id, word: params[:word])

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
