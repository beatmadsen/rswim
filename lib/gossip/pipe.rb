module Gossip
  class Pipe
    def initialize(q_in, q_out)
      @q_in = q_in
      @q_out = q_out
    end

    def send(address, message)
      @q_out << [address, message]
    end

    def receive
      @q_in.pop
    end
  end
end
