require 'json'

class WebServer
  def initialize(sensors, actuators)
    @sensors = sensors
    @actuators = actuators
  end

  HEADERS = {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => '*'}.freeze

  def call(env)
    symbolized_env = env.reduce({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    case symbolized_env
    in { PATH_INFO: '/sensors', REQUEST_METHOD: 'GET' }
      get_sensors
    in { PATH_INFO: '/actuators', REQUEST_METHOD: 'GET' }
      get_actuators
    in { PATH_INFO: '/actuators', REQUEST_METHOD: 'POST', QUERY_STRING: query }
      post_update_actuators(query)
    else
      [404, HEADERS, []]
    end
  end

  private

  def get_sensors
    response = @sensors.map { |sensor| sensor.slice(:name, :state) }.to_json
    return [200, HEADERS, [response]]
  end

  def get_actuators
    response = @actuators.map { |actuator| actuator.slice(:name, :state, :kind) }.to_json
    return [200, HEADERS , [response]]
  end

  def post_update_actuators(query)
    params = Rack::Utils.parse_nested_query(query)
    selected_actuator = @actuators.find { |actuator| actuator[:name] == params['name'] }
    if selected_actuator.nil?
      [404, HEADERS, []]
    else
      update_actuator(selected_actuator, params)

      [200, HEADERS, []]
    end
  end

  def update_actuator(actuator, params)
    stub = actuator[:stub]
    case actuator[:kind]
    when :air_conditioner
      temperature = State.new(value: params['value'].to_i)
      stub.change_temperature(temperature)
    when :lamp
      stub.toggle(Void.new)
    when :fire_sprinkler
      params[:value] == 'activate' ? stub.activate(Void.new) : stub.deactivate(Void.new)
    end
  end
end
