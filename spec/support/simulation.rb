class Simulation
  def initialize
    @bus = Bus.new


    @non_responsive_agent_ids = %w[mute1 mute2]

    @agents = ('a'..'d').map do |x|
      pipe = Bus::Pipe.new(x, @bus)
      SimulatedPauseAgent.new(pipe, x, ['a', 'b'] + @non_responsive_agent_ids)
    end

    @agents.concat(
      (1..20).map do |i|
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
    10_000.times do
      @agents.each(&:resume)
    end
  end
end
