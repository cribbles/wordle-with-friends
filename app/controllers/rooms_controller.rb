class RoomsController < ApplicationController
  def show
    @room = Room.find_by(name: params[:name])
    validate_session
    @guesses = @room.guesses
    @guess = Guess.new
  end

  def create
    @room = Room.generate!
    respond_to do |format|
      format.html { redirect_to room_path(@room.name) }
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
      puts params
      if @guess.save
        format.html { redirect_to room_path(params[:name]) }
      else
        format.turbo_stream do
          @room = Room.find(params[:name])
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
    if !session[:current_player_id] || session[:current_room] != @room.name
      render status: :forbidden, text: "Room is full" if @room.full?
      session[:current_player_id] = Player.create!(room: @room).id
      session[:current_room] = @room.name
    end
  end
end
