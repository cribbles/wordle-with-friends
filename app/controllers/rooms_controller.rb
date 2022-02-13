class RoomsController < ApplicationController
  def show
    @room = Room.find(params[:id])
    validate_session
    @guesses = @room.guesses
    @guess = Guess.new
  end

  def create
    @room = Room.generate!
    respond_to do |format|
      format.html { redirect_to room_path(@room.id) }
    end
  end

  def reset
    Room.find(params[:id]).reset!
    redirect_to room_path
  end

  def guess
    render status: :forbidden unless player_id = session[:current_player]
    @guess = Guess.new(word: params[:word], player: Player.find(player_id))
    respond_to do |format|
      puts params
      if @guess.save
        format.html { redirect_to room_path(params[:id]) }
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

  private

  def validate_session
    if !session[:current_player] || session[:current_room] != @room.id
      render status: :forbidden, text: "Room is full" if @room.full?
      session[:current_player] = Player.generate!(room: @room).id
      session[:current_room] = @room.id
    end
  end
end
