#!/usr/bin/env ruby
# lauches the game server
require './game_server.rb'
Thread.abort_on_exception = true

s = GameServer.new
trap("INT") { s.close; exit } # testing....

begin
  s.listen
rescue Interrupt => e # FIXME: not catching Ctrl-C ???
  puts
ensure
  puts "Closing..."
  s.close
end

# TODO: try this
#interrupted = false
#trap("INT") { interrupted = true }
# do HTTP request
#if interrupted
#  exit
#end
# rest of program

