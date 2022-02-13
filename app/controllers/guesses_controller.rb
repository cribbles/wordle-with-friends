class GuessesController < ApplicationController
  def create
    render status: :forbidden unless player_id = session[:current_player]
    @guess = Guess.new(player_id: player_id, word: params[:word])
    respond_to do |format|
      if @guess.save
        format.html { redirect_to room_path }
      else
        format.turbo_stream do
          @room = Room.find(params[:id])
          render turbo_stream: turbo_stream.replace(
            @room,
            partial: 'rooms/form',
            locals: { room: @room, guess: @guess }
          )
        end
      end
    end
  end
end
