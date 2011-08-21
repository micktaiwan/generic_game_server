class GameTable

  attr_accessor :name, :port

  def initialize(port, name)
    @port, @name  = port, name
    @context      = ZMQ::Context.new
  end

end

# All game servers shall derive from this class
class GameTableServer < GameTable
  # TODO: kills itself when no more clients

  attr_reader   :game_type, :nb_ports

  def initialize(port, name)
    super(port, name)
    @socket     = nil
    @thread     = nil
  end

  def listen
    @thread = Thread.new do
      context        = ZMQ::Context.new
      @socket         = context.socket(ZMQ::REP)
      @socket.bind("tcp://*:#@port")
      while true
        puts "Table listening..."
        command = @socket.recv_string
        puts "GameTable command: #{command}"
        if command[0..5] == "RENAME"
          @name = command[7..-1]
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
    @thread.kill if @thread
  end

end

