#!/usr/bin/env ruby
require 'chat_base'

class ChatDisplay < ChatBase

  def intialize(name)
    super(name)
  end

  def connect_to_table(name)
    super(name)
    @subscriber   = @context.socket(ZMQ::SUB)
    #@subscriber.connect("tcp://#@server_ip:#{@table_port+2}") # FIXME
    @subscriber.connect("tcp://#@server_ip:5003")
    @subscriber.setsockopt(ZMQ::SUBSCRIBE, "")
  end

  def loop
    while true
      puts @subscriber.recv_string
    end
  end

end

name = ARGV[0]
name = "ChatDisplay" if not name
c = ChatDisplay.new(name)
c.connect
c.connect_to_table("Lobby")
c.loop

