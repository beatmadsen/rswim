module Gossip
  class Protocol
    def initialize(pipe)
      @pipe = pipe
      @member_pool = MemberPool.new
    end

    def run
      n = 0
      loop do
        n += 1

        input = @pipe.receive
        input.each { |line| update_member(line) }

        delta_seconds = 0.010
        @member_pool.update_members(delta_seconds)

        output = @member_pool.prepare_output
        output.each { |ary| @pipe.send(ary) }

        @member_pool.ping_random_healthy_member if n % 1000 == 0 # TODO: protocol period
        @member_pool.status_report if n % 2000 == 0

        sleep delta_seconds
      end
    end

    private

    def update_member(line)
      @member_pool.update_member(line)
    rescue StandardError => e
      puts e.inspect
    end
  end
end
