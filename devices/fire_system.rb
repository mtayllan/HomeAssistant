require './actuators/fire_sprinkler_actuator'
require './sensors/smoke_sensor'

module Devices
  class FireSystem
    def initialize
      @sensor = SmokeSensor.new
      @actuator = FireSprinklerActuator.new(@sensor)

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

Devices::FireSystem.new
