class PlayersController < ApplicationController
  before_action :require_turbo_frame_header, except: [:create, :update]
  helper_method :get_name

  def create
    @room = Room.find(room_id)
    @player = Player.generate!(room: @room)
    session[room_id] = @player.id
  end

  def new
    @room = Room.find(room_id)
  end

  def show
    player = Player.find(params[:id])
    template = can_rename(player) ? 'edit' : 'show'
    render turbo_stream: turbo_stream.update(
      "name_player_#{player.id}",
      template: "players/#{template}",
      locals: { player: player }
    )
  end

  def update
    @player = Player.find(params[:id])
    @player.update!(name: params[:name])
    redirect_to room_path(@player.room)
  end

  private

  def room_id
    params[:room_id]
  end

  def get_name(player)
    player.name || "Player #{player.room.players.find_index(player) + 1}"
  end

  def can_rename(player)
    player.id === current_player_id && player.name.blank?
  end
end
