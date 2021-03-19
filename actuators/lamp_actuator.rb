require_relative './actuator_services_pb'
require_relative './actuator'

class LampActuator < Lamp::Service
  def initialize(sensor)
    @state = false
    @sensor = sensor
  end

  def run
    Actuator.new('Lamp', '50051', self)
  end

  def toggle(*)
    @state = !@state
    @sensor.factor = @state
    Response.new(success: true)
  end

  def get_state(*)
    State.new(value: @state ? 1 : 0)
  end
end



