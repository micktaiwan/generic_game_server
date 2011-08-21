require '../generic_client.rb'
require './chat_table.rb'

class ChatClient < GenericClient

  def initialize(ip, port, name)
    super(ip, port, name)
    @tables = []
  end

  def create_new_table(name)
    @server_socket.send_string("NEWTABLE Chat")
    rv = @server_socket.recv_string
    puts rv and exit if rv[0..4] == "ERROR"
    port     = rv.split(" ")[1].to_i
    return add_table(port,name)
  end

  def connect_to_table(name, create_if_necessary = false)
    table = get_local_table(name)
    return table if table

    request_all_game_tables
    tmp, tables = recv_string.split(' ')
    puts tables
    return create_new_table(name) if !tables

    tables = tables.split(";")
    table = get_table_by_name(tables, name)
    if not table
      return create_new_table(name)
    else
      return add_table(table[:port],table[:name])
    end
  end

private

  def get_table_by_name(tables, name)
    tables.each { |t|
      type, t = t.split('.')
      n, p = t.split(':')
      return {:port=> p.to_i, :name=>n} if n = name
      }
    return nil
  end

  def add_table(port, name)
    puts "Adding table #{name} and connecting to #@server_ip:#{port}"
    t = ChatTable.new(@server_ip, port, name)
    @tables << t
    t
  end

  def get_local_table(name)
    @tables.each { |t|
      return t if t.name == name
      }
    return nil
  end

end

