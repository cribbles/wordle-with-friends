class ApplicationController < ActionController::Base
  helper_method :logged_in, :current_player_id

  private

  def logged_in
    current_player_id.presence || false
  end

  def current_player_id
    session[room_id]
  end

  def room_id
    nil
  end
end
