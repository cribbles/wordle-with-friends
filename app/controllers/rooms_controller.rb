class RoomsController < ApplicationController
  def show
    @room = Room.find(room_id)
    ensure_first_player_exists
    @guess = Guess.new
  end

  def create
    @room = Room.generate!
    redirect_to room_path(@room)
  end

  def update
    @room = Room.find(params[:id])
    @room.reset!
  end

  private

  def room_id
    params[:id]
  end

  def ensure_first_player_exists
    if @room.empty?
      room_id = params[:id]
      player = Player.generate!(room_id: room_id)
      session[room_id] = player.session_token
    end
  end
end
