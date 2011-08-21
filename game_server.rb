# prerequisites:
# sudo gem install ffi ffi-rzmq
require 'rubygems'
require 'ffi-rzmq'
require './utils.rb'
require './game_table.rb'

# a game server launches as many as GameTableServer as necessary
# each of them listening of a different port
class GameServer

  include Utils

  def initialize(port)
    puts "ffi-rzmq version #{ZMQ::version}"
    @running      = true
    @tables       = []
    @taken_ports  = []
    @server_port  = port
    @games        = { # TODO: put this in a config file or do it automatically
      'Chat'=>'chat/chat_server.rb',
      'Dobble'=>'dobble/dobble_server.rb'
      }
    @games.each { |key, value|
      puts "Loading #{key}..."
      load value
      }
    @context = ZMQ::Context.new
    @socket = @context.socket(ZMQ::REP)
    @socket.bind("tcp://*:#@server_port")
    puts "Loaded all games. Listening for client commands."
  end

  def close
    @running = false
    @socket.close
    @tables.each { |t| t.close }
    @context.terminate
  end

  def listen
    while @running
      parse(@socket.recv_string)
    end # loop
  end

  def parse(command)
    #log("GameServer: #{command}")
    #log "id: #{@socket.getsockopt(ZMQ::IDENTITY)}"
    if command[0..7] == "NEWTABLE" # NEWTABLE gamename
      name = command[9..-1]
      @socket.send_string("ERROR Game #{name} does not exists") and return if !@games.include?(name)
      table, err = get_game_instance(name)
      if not table
        @socket.send_string("ERROR Error in game #{name}: #{err}")
        log("Error in game #{name}: #{err}")
        return
      end
      @socket.send_string("CREATED #{table.port} #{name}")
      log("Generic Server: Created a new table for #{name} on port #{table.port}")
    elsif command == "LISTTABLES"
      @socket.send_string("TABLES #{tables_names}")
    elsif command[0..9] == "CLIENTNAME" # a client gives us its friendly name
      @socket.send_string("CLIENTNAME")
      # TODO: use it :)
      log("#{command[10..-1]} gave his name")
    elsif command == "EXIT" # any client can shutdown the server...
      log("Client asked for exit")
      break
    else
      @socket.send_string("unknown command " + command)
    end
  end

  def get_port
    # FIXME: horrible....
    i = 0
    begin
      i += 1
      port = @server_port + i
    end while @taken_ports.include?(port) # FIXME: ports are not freed

    @taken_ports << port
    port
  end

  def tables_names
    @tables.map { |t| "#{t.game_type}.#{t.name}:#{t.port}" }.join(";")
  end

  def add_taken_ports(from, nb)
    p = from
    for i in (1..nb)
      @taken_ports << p+i
    end
  end

  def get_game_instance(class_name)
    port = get_port
    begin
      table =  eval("#{class_name}.new(#{port}, #{class_name})")
      add_taken_ports(port, table.nb_ports)
      @tables << table
      table.listen
      return [table, nil]
    rescue NameError => e
      return [nil, e.message]
    rescue Exception => e
      return [nil, e.message]
    end
  end

end

if __FILE__ == $0
  puts "This file does nothing itself. See main.rb"
end

