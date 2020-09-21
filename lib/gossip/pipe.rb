# frozen_string_literal: true

module Gossip
  class Pipe
    def self.simple
      Simple.new
    end

    def initialize(q_in, q_out)
      @q_in = q_in
      @q_out = q_out
    end

    def send(ary)
      @q_out << ary
    end

    # returns list of inputs. Empty if none have been received
    def inbound
      Array.new(@q_in.size) { @q_in.pop }.tap(&:compact!)
    end

    # returns list of outputs. Empty if none have been sent
    def outbound
      Array.new(@q_out.size) { @q_out.pop }.tap(&:compact!)
    end

    class Simple < Pipe
      attr_reader :q_in, :q_out

      def initialize
        @q_in, @q_out = 2.times.map { Queue.new }
        super(@q_in, @q_out)
      end
    end
  end
end
