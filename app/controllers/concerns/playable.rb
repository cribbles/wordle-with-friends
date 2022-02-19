module Playable
  extend ActiveSupport::Concern

  included { helper_method :logged_in? }

  private

  def replace_room_dashboard(room)
    turbo_stream.replace(
      :room_dashboard,
      partial: 'rooms/dashboard',
      locals: { room: room }
    )
  end

  def logged_in?
    !!session[params[:room_id]]
  end
end