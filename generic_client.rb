require 'rubygems'
require 'ffi-rzmq'

class GenericClient

  def initialize(name="Generic client")
    @context        = ZMQ::Context.new
    @server_socket  = @context.socket(ZMQ::REQ)
    @server_ip      = "localhost"
    @server_port    = 5000
    @client_name    = name
  end

  def connect
    @server_socket.connect("tcp://#@server_ip:#@server_port")
    @server_socket.send_string("CLIENTNAME #@client_name")
    @server_socket.recv_string
  end

  def request_all_game_tables
    @server_socket.send_string("LISTTABLES")
  end

  def recv_string
    @server_socket.recv_string
  end

end

if __FILE__ == $0
  puts "This file does nothing itself. You have to derive a new client from it."
end

