module Gossip
  class Member
    def initialize
      @state = MemberState.init
    end

    def update(elapsed_seconds)
      @state = @state.advance(elapsed_seconds)
    end

    def to_s
      @state.to_s
    end
  end

  module MemberState
    def self.init
      Init.new
    end

    class Init
      def initialize
        @life_time_seconds = 0
      end

      def advance(elapsed_seconds)
        @life_time_seconds += elapsed_seconds
        if @life_time_seconds > 10
          Next.new
        else
          self
        end
      end

      def to_s
        'init'
      end
    end

    class Next
      def advance(elapsed_seconds)
        self
      end

      def to_s
        'next'
      end
    end
  end

  class Protocol
    def initialize(pipe)
      @pipe = pipe
      @members = {}
    end

    def run
      t = Time.now
      loop do
        input = @pipe.receive
        update_member(input)
        t_old = t
        t = Time.now
        delta = t - t_old
        update_members(delta)

        # output
        out_member = @members[input.first]
        @pipe.send(input.first, out_member.to_s)
        sleep 0.1
      end
    end

    private

    def update_member(input)
      member_id, = input
      @members[member_id] ||= Member.new
    end

    def update_members(elapsed_seconds)
      @members.values.each { |m| m.update(elapsed_seconds) }
    end
  end
end
