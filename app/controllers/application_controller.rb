class ApplicationController < ActionController::Base
  helper_method :logged_in?, :current_player, :actionify_for

  private

  def logged_in?
    current_player_id.presence || false
  end

  def current_player
    Player.find_by(id: current_player_id)
  end

  def actionify_for(stimulus_controller_events)
    stimulus_controller_events.reduce('') do |actions, (controller, events)|
      transformer = events.is_a?(Enumerable) ? :to_actions : :to_action
      actions + send(transformer, controller.to_s.dasherize, events)
    end
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

  private

  def to_actions(stimulus_controller, actions)
    actions.map { |action| to_action(stimulus_controller, action) }.join(' ')
  end

  def to_action(stimulus_controller, action)
    "#{action}->#{stimulus_controller}##{action}"
  end
end
