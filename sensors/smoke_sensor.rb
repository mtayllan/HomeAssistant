# frozen_string_literal: true

require 'bunny'

class SmokeSensor
  attr_reader :smoke_perception
  attr_writer :actuator_stinguishing_fire
  attr_writer :fire_sprinkler

  def initialize
    @smoke_perception = 0.0
    @actuator_stinguishing_fire = false
  end

  def run
    connection = Bunny.new
    connection.start

    @channel = connection.create_channel

    @queue = @channel.queue('smoke.sensor1')

    loop do
      update_state
      send_state
      sleep 3
    end

    connection.close
  end

  def send_state
    @channel.default_exchange.publish(@smoke_perception.to_s, routing_key: @queue.name)
  end

  def update_state
    @smoke_perception = @actuator_stinguishing_fire ? rand(0..10) : rand(0..100)
    puts @smoke_perception

    if @smoke_perception >= 80
      @fire_sprinkler&.activate
    else
      @fire_sprinkler&.deactivate
    end
  end
end
