class Chat < GameTable

  def initialize(port)
    super(port)
    @game_type  = "Chat"
    @nb_port    = 2
    @context    = ZMQ::Context.new
    @puller     = nil
    @publisher  = nil
  end

  def listen
    super
    Thread.new do
      context        = ZMQ::Context.new
      @puller     = @context.socket(ZMQ::PULL)  # FIXME: so we have to close sockets ?
      @puller.bind("tcp://*:#{@port+1}")
      @publisher  = @context.socket(ZMQ::PUB)  # FIXME: so we have to close sockets ?
      @publisher.bind("tcp://*:#{@port+2}")
      while true
        puts "Chat puller listening..."
        msg = @puller.recv_string
        puts "MSG: #{msg}"
        @publisher.send_string(msg)
      end # loop
    end # thread
  end

  def process(command)
    @socket.send_string("Chat server: unknown command '#{command}'")
  end

  def close
    super
    @puller.close if @puller
    @publisher.close if @publisher
  end

end

if __FILE__ == $0
  puts "This file does nothing itself. run ../main.rb"
end

