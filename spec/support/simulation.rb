class Simulation
  def initialize
    @bus = Bus.new


    @non_responsive_agent_ids = %w[mute1 mute2]

    @normal_agents = ('a'..'d').map do |x|
      pipe = Bus::Pipe.new(x, @bus)
      SimulatedPauseAgent.new(pipe, x, ['a', 'b'] + @non_responsive_agent_ids)
    end

    @agents = []

    @agents.concat(@normal_agents)

    @agents.concat(
      (1..7).map do |i|
        x = "unstable-#{i}"
        pipe = Bus::IntermittentPipe.new(x, @bus)
        SimulatedPauseAgent.new(pipe, x, ['a', 'b'] + @non_responsive_agent_ids)
      end
    )

    @agents << 'emitter-1'.then do |x|
      pipe = Bus::Pipe.new(x, @bus)
      SimulatedPauseAgent.new(pipe, x, ['a'])
    end

    @agents << 'emitter-2'.then do |x|
      pipe = Bus::Pipe.new(x, @bus)
      SimulatedPauseAgent.new(pipe, x, ['b'])
    end

    @agents.concat(
      @non_responsive_agent_ids.map do |x|
        pipe = Bus::Pipe.new(x, @bus)
        NonResponsiveAgent.new(pipe)
      end
    )
  end

  def run
    @agents.each(&:run)

    @normal_agents[0].append_custom_state(:test, 'limbo')
    @normal_agents[1].append_custom_state(:start, 42)
    
    1_000.times do
      @agents.each(&:resume)
    end

    @normal_agents[0].append_custom_state(:test, 'updated')
    @normal_agents[2].append_custom_state(:start, 43)

    1_000.times do
      @agents.each(&:resume)
    end
  end
end
