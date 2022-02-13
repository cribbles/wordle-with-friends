class RoomsController < ApplicationController
  def show
    @room = Room.find(params[:id])
    @players = @room.players
    @guesses = @room.guesses
    @guess = Guess.new
    validate_session
  end

  def create
    @room = Room.generate!
    redirect_to room_path(@room.id)
  end

  def reset
    Room.find(params[:id]).reset!
    redirect_to room_path
  end

  private

  def validate_session
    validate_player
    validate_room
  end

  def validate_room
    session[:current_room] = @room.id
  end

  def validate_player
    if entering_new_room?
      forbid_entry if @room.full?
      join_as_new_player
    end
  end

  def join_as_new_player
    player = Player.generate!(room: @room)
    session[:current_player] = player.id
  end

  def forbid_entry
    render status: :forbidden, text: "Room is full"
  end

  def entering_new_room?
    session[:current_room] != @room.id
  end
end
