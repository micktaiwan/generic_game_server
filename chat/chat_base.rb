require '../generic_client.rb'

class ChatBase < GenericClient

  def intialize(name)
    super(name)
  end

  def create_new_table(name)
    @server_socket.send_string("NEWTABLE Chat")
    rv = @server_socket.recv_string
    puts rv and return if rv[0..4] == "ERROR"
    @table_port     = rv.split(" ")[1].to_i
    puts @table_port
    @table_socket   = @context.socket(ZMQ::REQ)
    @table_socket.connect("tcp://#@server_ip:#{@table_port}")
    @table_socket.send_string("RENAME #{name}")
    puts @table_socket.recv_string
  end

  def connect_to_table(name)
    request_all_game_tables
    tables = recv_string.split(" ")
    if not tables.include?("Chat:#{name}")
      create_new_table(name)
    else
      puts "TODO: connect to existing table"
    end
  end

end

