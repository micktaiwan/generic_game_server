#!/usr/bin/env ruby
# lauches the game server
require './game_server.rb'
Thread.abort_on_exception = true
s = GameServer.new
s.listen
s.close

