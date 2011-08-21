#!/usr/bin/env ruby
require './chat_client.rb'

class ChatDisplay < ChatClient

  def intialize(name)
    super(name)
  end

  def connect_to_table(name)
    super(name)
    t = get_local_table(name)
    raise "#{name} does not exist" if not t
    @subscriber   = @context.socket(ZMQ::SUB)
    @subscriber.connect("tcp://#@server_ip:#{t.port+2}")
    puts "connected to tcp://#@server_ip:#{t.port+2}"
  end

  def loop
    while true
      puts @subscriber.recv_string
    end
  end

  def close
    @subscriber.close
    super
  end

end

begin
  c = ChatDisplay.new("localhost", 5000, "ChatDisplay")
  c.connect
  c.connect_to_table("Lobby fails")
  c.loop
ensure
  c.close
end

