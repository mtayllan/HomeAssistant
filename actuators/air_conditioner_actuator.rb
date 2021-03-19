require_relative './actuator_services_pb'
require_relative './actuator'

class AirConditionerActuator < AirConditioner::Service
  def initialize(sensor)
    @state = 0
    @sensor = sensor
  end

  def run
    Actuator.new('AirConditioner', '50052', self)
  end

  def change_temperature(temperature, *)
    @state = temperature.value
    @sensor.factor = temperature.value
    Response.new(success: true)
  end

  def get_state(*)
    State.new(value: @state)
  end
end



