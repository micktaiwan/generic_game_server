require 'rubygems'
require 'zmq'

class Client

  def initialize
    @context = ZMQ::Context.new
    @socket = @context.socket(ZMQ::REQ)
    @server_ip = "localhost"
  end

  def connect
    @socket.connect("tcp://#{@server_ip}:5000")
  end

  # FIXME: just or testing
  def talk
    @socket.send("NEWTABLE Dobble")
    puts @socket.recv
    #@socket.send("EXIT")
  end

end

# FIXME: not generic at all :)
c = Client.new
c.connect
c.talk

