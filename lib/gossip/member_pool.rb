module Gossip
  class MemberPool
    def initialize
      @members = {}
      @ack_responder = AckResponder.new
    end

    def update_member(line)
      member_id, message = line
      message.strip!
      @ack_responder.schedule_ack(member_id) if message == 'ping'
      member = (@members[member_id] ||= Member.new(member_id))
      member.replied_with_ack if message == 'ack'
    end

    def update_members(elapsed_seconds)
      @members.values.each { |m| m.update(elapsed_seconds) }
    end

    def status_report
      StatusReport.print(@members)
    end

    def prepare_output
      # output
      x = @members.values
      x << @ack_responder
      # puts "### DEBUG x: #{x}" if x.size > 1
      x.flat_map(&:prepare_output)
    end

    def ping_random_healthy_member
      ms = @members.values.select(&:healthy?)
      return if ms.empty?

      index = ms.one? ? 0 : rand(ms.size)
      member = ms[index]
      member.ping
    end
  end
end
