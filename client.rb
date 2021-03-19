
require 'tty-prompt'
require 'tty-table'

class Client
  def initialize(sensors, actuators)
    @prompt = TTY::Prompt.new
    @sensors = sensors
    @actuators = actuators

    listen_commands
  end

  def listen_commands
    loop do
      key = @prompt.keypress(timeout: 1) # blocking
      if key.nil?
        output
      else
        request_update_actuator
      end
    end
  end

  def output
    rows = @sensors.map { |sensor| [sensor[:name], sensor[:value]] }
    table = TTY::Table.new(['Dispositivo', 'Estado'], rows).render(:unicode, alignments: %i[left center])
    @prompt.say("\e[H\e[2J#{table}\nPressione qualquer tecla para alterar um atuador.")
  end

  def request_update_actuator
    name = @prompt.select('Selecione um atuador:', @actuators.map { |act| act[:name] })
    selected_actuator = @actuators.find { |act| act[:name] == name }
    stub = selected_actuator[:stub]

    case selected_actuator[:kind]
    when :air_conditioner
      state = @prompt.ask('Qual valor deseja?')
      temperature = State.new(value: state.to_i)
      stub.change_temperature(temperature)
    when :lamp
      stub.toggle(Void.new)
    when :fire_sprinkler
      fire_sprinker_options = {'Ativar' => true, 'Desativar' => false}

      enable = @prompt.select('Deseja ativar ou desativar?', fire_sprinker_options)

      enable ? stub.activate(Void.new) : stub.deactivate(Void.new)
    end
  end
end


