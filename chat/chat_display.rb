#!/usr/bin/env ruby
require '../generic_client'

class ChatDisplay < GenericClient

  def intialize(name)
    super(name)
  end

  def create_new_table(name)
    @server_socket.send_string("NEWTABLE Chat")
    @table_port     = @server_socket.recv_string.split(" ")[1].to_i
    puts @table_port
    @table_socket   = @context.socket(ZMQ::REQ)
    @table_socket.connect("tcp://#@server_ip:#@table_port")
    @table_socket.send_string("RENAME #{name}")
    puts @table_socket.recv_string
  end

end

name = ARGV[0]
name = "Chat client" if not name
c = ChatDisplay.new(name)
c.connect
c.create_new_table("Lobby")
c.request_all_game_tables
puts c.recv_string

