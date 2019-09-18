module Gossip
  class Protocol
    def initialize(pipe)
      @pipe = pipe
    end

    def run
      loop do
        input = @pipe.receive
        @pipe.send(42, "Out: #{input}")
      end
    end
  end
end
