# frozen_string_literal: true

module Gossip
  class Pipe
    def initialize(q_in, q_out)
      @q_in = q_in
      @q_out = q_out
    end

    def send(ary)
      @q_out << ary
    end

    # returns list of inputs. Empty if none have been received
    def receive
      Array.new(@q_in.size) { @q_in.pop }.tap(&:compact!)
    end
  end
end
