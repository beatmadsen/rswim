
class Agent
  def initialize
    @bus = Bus.new
    @seed_member_ids = ('a' .. 'z').to_a
    @protocols = @seed_member_ids.map do |x|
      pipe = Bus::Pipe.new(x, @bus)
      SimulatedPauseProtocol.new(pipe, x, @seed_member_ids)
    end
  end

  def run
    @protocols.each(&:run)
    1000.times do
      @protocols.each(&:resume)
    end
  end

end
