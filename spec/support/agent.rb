
class Agent
  def initialize
    @bus = Bus.new
    @seed_member_ids = ('a' .. 'z').to_a
    @pipes = @seed_member_ids.map { |x| Bus::Pipe.new(x, @bus) }
    @protocols = @pipes.map { |p| SimulatedPauseProtocol.new(p, @seed_member_ids) }
  end

  def run
    @protocols.each(&:run)
    1000.times do
      @protocols.each(&:resume)
    end
  end

end
