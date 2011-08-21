require '../game_table.rb'

class ChatTable < GameTable

  def initialize(server_ip, port, name)
    super(port, name)
    @server_ip = server_ip
    @table_socket   = @context.socket(ZMQ::REQ)
    @table_socket.connect("tcp://#@server_ip:#@port")

    # FIXME: should not rename table everytime we create a table object
    @table_socket.send_string("RENAME #{name}")
    puts @table_socket.recv_string
  end

end

