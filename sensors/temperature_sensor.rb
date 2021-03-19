# frozen_string_literal: true

require 'bunny'

class TemperatureSensor
  attr_writer :factor
  attr_reader :state

  def initialize
    @state = 0
    @factor = 0
  end

  def run
    connection = Bunny.new
    connection.start

    @channel = connection.create_channel

    @queue = @channel.queue('temperature.sensor1')

    loop do
      update_state
      send_state
      sleep 3
    end

    connection.close
  end

  def send_state
    @channel.default_exchange.publish(@state.to_s, routing_key: @queue.name)
  end

  def update_state
    @state = @factor + rand(-3..3)
    puts @state
  end
end
