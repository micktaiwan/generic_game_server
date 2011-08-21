require 'rubygems'
require 'ffi-rzmq'

class GenericClient

  def initialize(ip, port, name="Generic client")
    Thread.abort_on_exception = true
    @server_ip      = ip
    @server_port    = port
    @client_name    = name
  end

  def connect
    @context        = ZMQ::Context.new
    @server_socket  = @context.socket(ZMQ::REQ)
    @server_socket.connect("tcp://#@server_ip:#@server_port")
    @server_socket.send_string("CLIENTNAME #@client_name")
    return @server_socket.recv_string
  end

  def request_all_game_tables
    @server_socket.send_string("LISTTABLES")
  end

  def recv_string
    @server_socket.recv_string
  end

  def close
    @server_socket.close if @server_socket
    @context.terminate if @context
  end

end

if __FILE__ == $0
  puts "This file does nothing itself. You have to derive a new client from it."
end

