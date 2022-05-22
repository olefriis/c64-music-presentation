#!/usr/bin/env ruby

require 'bundler/setup'
require 'ruby-osc'
require 'mos6510'
require './lib/file_reader'
require './lib/sid'
require './lib/voice'

if ARGV.length < 1 || ARGV.length > 2
  puts "Usage: #{$0} <file> [song]"
  puts "  <file> is the path to a .sid file"
  puts "  [song] is the number of the song to play from the file"
  exit 1
end

sid_file = FileReader.read(ARGV[0])
song = ARGV.length > 1 ? ARGV[1].to_i : sid_file.start_song

osc_client = OSC::Client.new 4560
sid = Sid.new(osc_client)
cpu = Mos6510::Cpu.new(sid: sid)
load_address = sid_file.data[0] + (sid_file.data[1] << 8)
cpu.load(sid_file.data[2..-1], from: load_address)
cpu.start

play_address = sid_file.play_address
if play_address == 0
  cpu.jsr sid_file.init_address
  play_address = (cpu.peek(0x0315) << 8) + cpu.peek(0x0314)
  STDERR.puts "New play address #{play_address}"
end

STDERR.puts "Playing song #{song} of #{sid_file.songs}..."
cpu.jsr sid_file.init_address, song - 1
run = true

# Run playback in separate thread so we can stop it from the main thread
thread = Thread.new do
  tick = 1.0 / 50
  next_time = Time.now + tick
  while run
    sleep [0, (next_time - Time.now).to_f].max
    next_time += tick

    cpu.jsr play_address
    sid.finish_frame
  end
end

# Wait for user to press enter, then stop the playback
g = STDIN.gets
run = false
thread.join

osc_client.send OSC::Message.new('/trigger', 0, 0, 0, 0)
osc_client.send OSC::Message.new('/trigger', 1, 0, 0, 0)
osc_client.send OSC::Message.new('/trigger', 2, 0, 0, 0)
