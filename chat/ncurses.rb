require 'rubygems'
require 'ncurses'
require './chat_client.rb'

class ChatUI < ChatClient

  def initialize(ip, port, name)
    super(ip, port, name)
  end

  def init
    Ncurses.initscr
    r,c = [],[]
    Ncurses.getmaxyx(Ncurses.stdscr,r,c)
    x = 0
    y = 0
    h = r[0]-3
    w = c[0]-2
    @win = Ncurses.newwin(h, w, y, x)
    x = 0
    y = r[0]-3
    h = 3
    w = c[0]-2
    @win.scrollok(true)
    Ncurses.noecho
    #@win.wrefresh
    @win.wprintw("Connecting...\n")
    @win.wrefresh
    connect
    @win.wrefresh
    connect_to_table("Lobby")
    @input = Ncurses.newwin(h, w, y, x)
    @input.box(0, 0)
    @input.mvwprintw(1,1,">")
    @input.wrefresh
  end

  def close
    if @win
      Ncurses.delwin(@win)
      @win = nil
    end
    if @input
      Ncurses.delwin(@input)
      @input = nil
    end
    Ncurses.endwin
    @subscriber.close if @subscriber
    super
  end

  def loop
    # listening thread
    Thread.new do
      while true
        @win.wprintw(@subscriber.recv_string)
        @win.wrefresh
        @input.wrefresh
      end
    end
    # input loop
    while true
      @input.mvwprintw(1,1, ">")
      @input.wrefresh
      input = STDIN.gets
      @pusher.send_string("#@client_name: #{input}")
    end
  end

  def connect_to_table(name)
    super(name, true)
    t = get_local_table(name)
    raise "Table does not exist" if not t
    @pusher   = @context.socket(ZMQ::PUSH)
    @pusher.connect("tcp://#@server_ip:#{t.port+1}")

    @subscriber   = @context.socket(ZMQ::SUB)
    @subscriber.connect("tcp://#@server_ip:#{t.port+2}")
    @subscriber.setsockopt(ZMQ::SUBSCRIBE, "")
    @win.wprintw("Connected to tcp://#@server_ip:#{t.port+2}\n")
    @win.wrefresh
  end

end

begin
  print "name: "
  name = gets.chomp

  win = ChatUI.new("localhost",5000,name)
  win.init
  win.loop
rescue Interrupt => e
  puts 'Interrupted'
rescue Exception => e
  win.close if win
  puts e
  puts e.backtrace
ensure
  win.close if win
end

