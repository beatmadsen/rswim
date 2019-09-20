module Gossip
  class Protocol
    def initialize(pipe)
      @pipe = pipe
      @members = {}
    end

    def run
      t = Time.now
      loop do
        input = @pipe.receive
        update_member(input) unless input.nil?
        t_old = t
        t = Time.now
        delta = t - t_old
        update_members(delta)

        # output
        output = @members.values.flat_map(&:prepare_output)
        output.each do |ary|
          @pipe.send(ary)
        end
        sleep 0.1
      end
    end

    private

    def update_member(input)
      member_id, = input
      @members[member_id] ||= Member.new(member_id)
    end

    def update_members(elapsed_seconds)
      @members.values.each { |m| m.update(elapsed_seconds) }
    end
  end
end
