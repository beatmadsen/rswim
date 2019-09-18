#!/usr/bin/env ruby
require "bundler/setup"
require 'gossip'
puts "Ruby version: #{RUBY_VERSION}"


q_in, q_out = 2.times.map { Queue.new }
pipe = Gossip::Pipe.new(q_in, q_out)
protocol = Gossip::Protocol.new(pipe)

# Protocol thread
Thread.new do
  protocol.run
end

# Output thread (stdout)
Thread.new do
  loop do
    receiver, message = q_out.pop
    puts "Message for #{receiver}: '#{message}'"
  end
end

# Input thread (stdin)
puts "Ready\n"
begin
  loop do
    input = gets
    break if input.nil?
    q_in << input.strip
  end
rescue Interrupt
end
puts "\nDone"
