module Gossip
  class Pipe
    def initialize(q_in, q_out)
      @q_in = q_in
      @q_out = q_out
    end

    def send(ary)
      @q_out << ary
    end

    def receive
      @q_in.pop unless @q_in.empty?
    end
  end
end
