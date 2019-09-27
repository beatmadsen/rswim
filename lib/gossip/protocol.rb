module Gossip
  class Protocol
    def initialize(pipe)
      @pipe = pipe
      @members = {}
      @ack_responder = AckResponder.new
    end

    def run
      n = 0
      loop do
        n += 1

        input = @pipe.receive
        input.each { |line| update_member(line) }

        delta_seconds = 0.010
        update_members(delta_seconds)

        # output
        x = @members.values
        x << @ack_responder
        # puts "### DEBUG x: #{x}" if x.size > 1
        output = x.flat_map(&:prepare_output)
        output.each { |ary| @pipe.send(ary) }

        ping_member if n % 1000 == 0 # TODO: protocol period
        print_report if n % 2000 == 0

        sleep delta_seconds
      end
    end

    private

    def ping_member
      ms = @members.values.select(&:healthy?)
      return if ms.empty?

      index = ms.one? ? 0 : rand(ms.size)
      member = ms[index]
      member.ping
    end

    def print_report; end

    def update_member(line)
      member_id, message = line
      message.strip!
      @ack_responder.schedule_ack(member_id) if message == 'ping'
      member = @members[member_id] ||= Member.new(member_id)
      member.replied_with_ack if message == 'ack'
    rescue StandardError => e
      puts e.inspect
    end

    def update_members(elapsed_seconds)
      @members.values.each { |m| m.update(elapsed_seconds) }
    end
  end
end
