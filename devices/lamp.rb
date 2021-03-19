require './actuators/lamp_actuator'
require './sensors/light_sensor'

module Devices
  class Lamp
    def initialize
      @sensor = LightSensor.new
      @actuator = LampActuator.new(@sensor)

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

Devices::Lamp.new
