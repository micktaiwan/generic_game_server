#!/usr/bin/env ruby
# lauches the game server
require 'game_server'
s = GameServer.new
s.listen

