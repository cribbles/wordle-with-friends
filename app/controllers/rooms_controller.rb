class RoomsController < ApplicationController
  helper_method :logged_in?
  
  def show
    @room = Room.find(params[:id])
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
    Room.find(params[:id]).reset!
    redirect_to room_path
  end

  private

  def ensure_first_player_exists
    if @room.empty?
      room_id = params[:id]
      session[room_id] = Player.generate!(room_id: room_id).id
    end
  end

  def logged_in?
    !!session[params[:id]]
  end
end
