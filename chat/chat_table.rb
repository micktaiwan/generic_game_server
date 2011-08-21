require '../game_table.rb'

class ChatTable < GameTable

  attr_reader :table_socket

  def initialize(server_ip, port, name)
    super(port, name)
    @server_ip = server_ip
    # table_socket is used to send commands to the table
    @table_socket   = @context.socket(ZMQ::REQ)
    @table_socket.connect("tcp://#@server_ip:#@port")
  end

end

