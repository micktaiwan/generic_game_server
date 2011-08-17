class Chat

  def initialize
  end

  def game_type
    "Chat"
  end

  def process(command)
    @socket.send_string("Chat server: unknown command '#{command}'")
  end

end

