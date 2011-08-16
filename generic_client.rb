require 'rubygems'
require 'zmq'

class GenericClient

  def initialize(name="Generic client")
    @context = ZMQ::Context.new
    @socket = @context.socket(ZMQ::REQ)
    @server_ip = "localhost"
    @client_name = name
  end

  def connect
    @socket.connect("tcp://#@server_ip:5000")
    @socket.send("NAME #@client_name")
    @socket.recv
  end

end

if __FILE__ == $0
  puts "This file does nothing itself. You have to derive a new client from it."
end

