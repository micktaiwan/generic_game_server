# prerequisites:
# sudo gem install ffi ffi-rzmq
require 'rubygems'
require 'ffi-rzmq'
require './utils.rb'

# a game server launches as many as GameTable as necessary
# each of them listening of a different port
class GameServer

  include Utils

  def initialize
    puts "ffi-rzmq version #{ZMQ::version}"
    @tables       = []
    @taken_ports  = []
    @server_port  = 5000
    @games        = { # TODO: put this in a config file or do it automatically
      'Chat'=>'chat/chat_server.rb',
      'Dobble'=>'dobble/dobble_server.rb'
      }
    @games.each { |key, value|
      puts "Loading #{key}..."
      load value
      }
    @context = ZMQ::Context.new
    @socket = @context.socket(ZMQ::REP)  # FIXME: so we have to close sockets ?
    @socket.bind("tcp://*:#@server_port")
    puts "Loaded all games. Listening for client commands."
  end

  def close
    @socket.close
    @tables.each { |t| t.close }
    @context.terminate
  end

  def listen
    while true
      begin
        parse(@socket.recv_string)
      rescue Exception => e
        log(e.message)
        raise e
      end
    end # loop
  end

  def parse(command)
    puts "GameServer: #{command}"
    #log "id: #{@socket.getsockopt(ZMQ::IDENTITY)}"
    if command[0..7] == "NEWTABLE" # NEWTABLE gamename
      port = get_port
      name = command[9..-1]
      @socket.send_string("ERROR Game #{name} does not exists") and return if !@games.include?(name)
      table, err = get_game_instance(name, port)
      @socket.send_string("ERROR Error in game #{name}: #{err}") and return if not table
      @socket.send_string("CREATED #{port} #{name}")
      log("Created a new table for #{name}")
    elsif command == "LISTTABLES"
      @socket.send_string("TABLES #{tables_names}")
    elsif command[0..9] == "CLIENTNAME" # a client gives us its friendly name
      @socket.send_string("CLIENTNAME")
      # TODO: use it :)
      log("#{command[10..-1]} gave his name")
    #elsif command == "EXIT" # FIXME: any client can shutdown the server
    #  break
    else
      @socket.send_string("unknown command " + command)
    end
  end

  def get_port
    i = 0
    begin
      i += 1
      port = @server_port + i
    end while @taken_ports.include?(port) # FIXME: ports are not freed

    @taken_ports << port
    port
  end

  def tables_names
    @tables.map { |t| "#{t.game_type}:#{t.table_name}" }.join(", ")
  end

  def get_game_instance(class_name, port)
    begin
      table =  eval("#{class_name}.new(#{port})")
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

class GameTable
  # TODO: kills itself when no more clients

  attr_accessor :table_name
  attr_reader   :game_type, :nb_ports

  def initialize(port)
    @port           = port
    @table_name     = "No name"
    @socket         = nil
  end

  def listen
    Thread.new do
      context        = ZMQ::Context.new
      @socket         = context.socket(ZMQ::REP)
      @socket.bind("tcp://*:#@port") # FIXME: so we have to close sockets ?
      while true
        puts "Table listening..."
        command = @socket.recv_string
        puts "GameTable command: #{command}"
        if command[0..5] == "RENAME"
          @table_name = command[7..-1]
          @socket.send_string("RENAME OK")
        else
          process(command)
        end
        break if command == "DESTROY"
      end # loop
    end # thread
  end

  def process
    raise "process needs to be overridden"
  end

  def close
    @socket.close if @socket
  end

end

if __FILE__ == $0
  puts "This file does nothing itself. You have to derive a new server from it. See main.rb"
end

