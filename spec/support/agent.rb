# The idea here is to have two different kinds of agents in test;
# one that runs the full protocol,
# and one that carries a predefined list of outbound messages and expected inbound messages.
# We can make these talk together and verify that the sequence progresses as expected


class Agent
  def initialize(pipe)
    @pipe = pipe.inverse
  end

  def start
    Thread.new do
      loop do
        ary = @pipe.inbound

      end
    end
  end
end
