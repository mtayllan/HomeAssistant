require_relative './actuator_services_pb'
require_relative './actuator'

class FireSprinklerActuator < FireSprinkler::Service
  def initialize(sensor)
    @state = false
    @sensor = sensor
    @sensor.fire_sprinkler = self
  end

  def run
    Actuator.new('FireSprinkler', '4000', self)
  end

  def activate(*)
    @state = true
    @sensor.actuator_stinguishing_fire = true
    Response.new(success: true)
  end

  def deactivate(*)
    @state = false
    @sensor.actuator_stinguishing_fire = false
    Response.new(success: true)
  end

  def get_state(*)
    State.new(value: @state ? 1 : 0)
  end
end
