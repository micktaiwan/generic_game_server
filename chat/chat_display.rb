#!/usr/bin/env ruby
require './chat_base.rb'

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

c = ChatDisplay.new("ChatDisplay")
c.connect
c.connect_to_table("Lobby") # FIXME: must be the first table on port 5001 (5003 for display)
c.loop

