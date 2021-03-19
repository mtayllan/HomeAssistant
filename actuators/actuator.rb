require 'grpc'

class Actuator
  def initialize(name, port, impl)
    @name = name
    @port = port

    server = GRPC::RpcServer.new
    server.add_http2_port("0.0.0.0:#{@port}", :this_port_is_insecure)
    server.handle(impl)
    server.run_till_terminated_or_interrupted(['TERM'])
  end
end
