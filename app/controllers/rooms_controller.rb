class RoomsController < ApplicationController
  def show
    @room = Room.find(room_id)
    ensure_first_player_exists
    @players = @room.players
    @guesses = @room.guesses
    @guess = Guess.new
  end

  def create
    @room = Room.generate!
    redirect_to room_path(@room.id)
  end

  def update
    room = Room.find(params[:id])
    room.reset!
    redirect_to :back
  end

  private

  def ensure_first_player_exists
    if @room.empty?
      room_id = params[:id]
      session[room_id] = Player.generate!(room_id: room_id).id
    end
  end

  def room_id
    params[:id]
  end
end
