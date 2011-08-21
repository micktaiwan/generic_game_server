#!/usr/bin/env ruby
require './chat_client.rb'

class ChatInput < ChatClient

  def initialize(ip,port,name)
    super(ip,port,name)
  end

  def connect_to_table(name)
    super(name, true)
    t = get_local_table(name)
    raise "Table does not exist" if not t
    @pusher   = @context.socket(ZMQ::PUSH)
    @pusher.connect("tcp://#@server_ip:#{t.port+1}")
    puts "connected to tcp://#@server_ip:#{t.port+1}"
  end

  def loop
    while true
      print ">"
      input = STDIN.gets
      @pusher.send_string("#@client_name: #{input}")
    end
  end

  def close
    @pusher.close if @pusher
    super
  end

end

name = ARGV[0]
if not name
  puts "provide a name with 'chat_input name'"
  exit
end
begin
  c = ChatInput.new("localhost", 5000, name)
  c.connect
  c.connect_to_table("Lobby")
  c.loop
ensure
  c.close
end

