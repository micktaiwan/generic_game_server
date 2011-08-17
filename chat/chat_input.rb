#!/usr/bin/env ruby
require './chat_base.rb'

class ChatInput < ChatBase

  def intialize(name)
    super(name)
  end

  def create_new_table(name)
    super(name)
  end

  def connect_to_table(name)
    super(name)
    @pusher   = @context.socket(ZMQ::PUSH)
    @pusher.connect("tcp://#@server_ip:#{@table_port+1}")
  end

  def loop
    while true
      input = gets
      @pusher.send_string("#@client_name: #{input}")
    end
  end

end

name = ARGV[0]
name = "ChatInput" if not name
c = ChatInput.new(name)
c.connect
c.connect_to_table("Lobby")
c.loop

