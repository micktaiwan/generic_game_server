require 'rubygems'
require 'zmq'
require 'utils'

# a game server launches as many as GameTable as necessary
# each of them listening of a different port
class GameServer

  include Utils

  def initialize
    @tables       = []
    @taken_ports  = []
    @server_port  = 5000
    @games        = {
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

  def listen
    while true
      command = @socket.recv
      if command[0..7] == "NEWTABLE" # NEWTABLE gamename
        port = get_port
        name = command[9..-1]
        @socket.send("ERROR Game #{name} does not exists") and next if !@games.include?(name)
        instance = get_game_instance(name)
        @socket.send("ERROR Error in game #{name}: #{instance}") and next if instance.class.to_s != name
        @tables << GameTable.new(port, instance)
        @socket.send("CREATED #{port} #{name}")
        log("Created a new table for #{name}")
      elsif command == "EXIT" # FIXME: any client can shutdown the server
        break
      else
        @socket.send("unknown command " + command)
      end
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

  def get_game_instance(class_name)
    begin
      return eval("#{class_name}.new")
    rescue NameError => e
      return e.message
    rescue Exception => e
      return e.message
    end

  end

end

class GameTable
  # TODO: kills itself when no more clients

  def initialize(port, game_instance)
    @game_instance  = game_instance
    @context        = ZMQ::Context.new
    @socket         = @context.socket(ZMQ::REP)
    @socket.bind("tcp://*:#{port}")
  end

end

