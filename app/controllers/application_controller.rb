class ApplicationController < ActionController::Base
  helper_method :logged_in?, :current_player, :to_actions

  private

  def logged_in?
    current_player_id.presence || false
  end

  def current_player
    Player.find_by(id: current_player_id)
  end

  def to_actions(stimulus_controller, actions)
    actions.map { |action| "#{action}->player-name##{action}" }.join(' ')
  end

  def require_login
    render status: :forbidden unless logged_in?
  end

  def require_turbo_frame_header
    render status: :forbidden unless is_turbo_frame_request?
  end

  def is_turbo_frame_request?
    !!request.headers['turbo-frame']
  end

  def current_player_id
    session[room_id]
  end

  def room_id
    nil
  end
end
