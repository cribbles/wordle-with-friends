class PlayersController < ApplicationController
  before_action :require_turbo_frame_header, only: :new

  def create
    @room = Room.find(room_id)
    player = Player.generate!(room: @room)
    session[room_id] = player.id
  end

  def new
    @room = Room.find(room_id)
  end

  private

  def room_id
    params[:room_id]
  end
end
