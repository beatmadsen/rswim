# frozen_string_literal: true

# Pipe that allows tests to control inputs to agents via #recieve(message) and read output from agents via #out()
class TestPipe
  # Used by test
  attr_reader :out

  def initialize
    @in = []
    @out = []
  end

  # Used by test
  def receive(message)
    @in << message
  end

  # Used by agent
  def send(message)
    @out << message
  end

  # Used by agent
  def inbound
    @in
  end
end
