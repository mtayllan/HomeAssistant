require './actuators/air_conditioner_actuator'
require './sensors/temperature_sensor'

module Devices
  class AirConditioner
    def initialize
      @sensor = TemperatureSensor.new
      @actuator = AirConditionerActuator.new(@sensor)

      t1 = Thread.new do
        @actuator.run
      end

      t2 = Thread.new do
        @sensor.run
      end

      t1.join
      t2.join
    rescue Interrupt
      puts 'Closing...'
    end
  end
end

Devices::AirConditioner.new
