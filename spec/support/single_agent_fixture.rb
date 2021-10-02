# frozen_string_literal: true

class SingleAgentFixture
  def initialize
    @pipe = TestPipe.new
    @agent = SimulatedPauseAgent.new(@pipe, 'test-agent', %w[seed-a seed-b])
    # TODO: deterministic step
    @agent.next_pause_seconds = 0.001
  end

  def send_to_agent(message)
    @pipe.receive(message)
  end

  def new_messages_from_agent
    Array.new(@pipe.out.size) { @pipe.out.pop }.tap(&:compact!)
  end

  def append_custom_state(key, value)
    @agent.append_custom_state(key, value)
  end

  def run
    @agent.run
  end

  # run until next output available
  def step
    raise 'drain pipe out' unless @pipe.out.empty?

    @agent.resume while @pipe.out.empty?
  end
end
