# frozen_string_literal: true

require 'bunny'
require './client'
require './actuators/actuator_services_pb'
require './web_server'
require 'rack'

class Home
  def initialize
    @sensors = []
    @actuators = []
    sensors_thread = Thread.new { start_sensors_comms }
    actuator_thread = Thread.new { start_actuators_comms }
    webserver_thread = Thread.new { start_webserver }

    sensors_thread.join
    actuator_thread.join
    webserver_thread.join
  rescue Interrupt
    @sensors_connection.close

    exit(0)
  end

  def start_sensors_comms
    @sensors_connection = Bunny.new
    @sensors_connection.start

    channel = @sensors_connection.create_channel
    @sensors.push(*[
      { name: 'light.sensor1' },
      { name: 'temperature.sensor1' },
      { name: 'smoke.sensor1' }
    ])

    @sensors.each do |sensor|
      sensor[:queue] = channel.queue(sensor[:name])

      sensor[:queue].subscribe do |_, _, body|
        sensor[:state] = body
        sensor[:last_update] = Time.now
      end
    end

    loop do
      @sensors.each do |sensor|
        next if sensor[:last_update].nil?

        last_update_diff = Time.now - sensor[:last_update]
        if last_update_diff > 3
          sensor[:state] = nil
        end
      end

      sleep 5
    end
  end

  def start_actuators_comms
    @actuators.push(*[
      {
        name: 'Ar Condicionado 1',
        stub: AirConditioner::Stub.new('localhost:50052', :this_channel_is_insecure),
        kind: :air_conditioner
      },
      {
        name: 'Rociador de Incêndio 1',
        stub: FireSprinkler::Stub.new('localhost:4000', :this_channel_is_insecure),
        kind: :fire_sprinkler
      },
      {
        name: 'Lâmpada 1',
        stub: Lamp::Stub.new('localhost:50051', :this_channel_is_insecure),
        kind: :lamp
      }
    ])

    loop do
      @actuators.each do |actuator|
        begin
          state = actuator[:stub].get_state(Void.new)
          case actuator[:kind]
          when :air_conditioner
            actuator[:state] = state.value
          when :lamp
            actuator[:state] = state.value == 1
          when :fire_sprinkler
            actuator[:state] = state.value == 1
          end
        rescue GRPC::Unavailable
          actuator[:state] = nil
        end
      end

      sleep 1
    end
  end

  def start_webserver
    Rack::Handler::WEBrick.run(WebServer.new(@sensors, @actuators), :Port => 9292)
  end
end

Home.new
