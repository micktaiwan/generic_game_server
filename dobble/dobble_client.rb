#!/usr/bin/env ruby
require '../generic_client'

class DobbleClient < GenericClient

  def intialize(name)
    super(name)
  end

  def create_new_table
    @socket.send("NEWTABLE Dobble")
    puts @socket.recv
  end

end

name = ARGV[0]
name = "Dobble client" if not name
c = DobbleClient.new(name)
c.connect
c.create_new_table

