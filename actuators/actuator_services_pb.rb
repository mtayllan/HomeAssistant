# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: actuator.proto for package ''

require 'grpc'
require_relative './actuator_pb'

module Lamp
  class Service

    include GRPC::GenericService

    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode
    self.service_name = 'Lamp'

    rpc :Toggle, ::Void, ::Response
    rpc :GetState, ::Void, ::State
  end

  Stub = Service.rpc_stub_class
end
module AirConditioner
  class Service

    include GRPC::GenericService

    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode
    self.service_name = 'AirConditioner'

    rpc :ChangeTemperature, ::State, ::Response
    rpc :GetState, ::Void, ::State
  end

  Stub = Service.rpc_stub_class
end
module FireSprinkler
  class Service

    include GRPC::GenericService

    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode
    self.service_name = 'FireSprinkler'

    rpc :Activate, ::Void, ::Response
    rpc :Deactivate, ::Void, ::Response
    rpc :GetState, ::Void, ::State
  end

  Stub = Service.rpc_stub_class
end
