class RoomsController < ApplicationController
  def show
    @room = Room.find(params[:id])
    if !session[:current_player_id]
      render status: :forbidden, text: "Room is full" if @room.full?
      session[:current_player_id] = Player.create!(room: @room).id
    end
    @guesses = @room.guesses.order(id: :desc)
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
    render status: :forbidden unless player_id = session[:current_player_id]
    @guess = Guess.new(word: params[:word], player_id: player_id)
    respond_to do |format|
      if @guess.save
        format.html { redirect_to room_path(params[:room_id]) }
      else
        format.turbo_stream do
          @room = Room.find(params[:room_id])
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
