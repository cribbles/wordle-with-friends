class GuessesController < ApplicationController
  def create
    room_id = params[:room_id]
    render status: :forbidden unless player_id = session[room_id]

    @room = Room.find(room_id)
    @guess = Guess.new(player_id: player_id, word: params[:word])

    respond_to do |format|
      if @guess.save
        format.html { redirect_to room_path(room_id) }
        format.turbo_stream do
          if @room.over?
            render turbo_stream: [
              replace_room_dashboard,
              replace_room_form
            ]
          else
            render turbo_stream: replace_room_form
          end
        end
      else
        format.turbo_stream do
          render turbo_stream: replace_room_form(@guess)
        end
      end
    end
  end

  private

  def replace_room_dashboard
    turbo_stream.replace(
      @room,
      partial: 'rooms/dashboard',
      locals: { room: @room, logged_in?: true }
    )
  end

  def replace_room_form(guess = Guess.new)
    turbo_stream.replace(
      @room,
      partial: 'rooms/form',
      locals: { room: @room, guess: guess }
    )
  end
end
