# frozen_string_literal: true

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
      member = member(member_id)
      case message
      when 'ack'
        member.replied_with_ack
      when /^ping-req (.+)/
        target_id = Regexp.last_match(1)
        target = member(target_id)
        target.forward_ping(member_id)
      end
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

    def ping_request_to_k_members(target_id)
      @members.values.select(&:healthy?).take(K).each { |m| m.ping_request(target_id) }
    end

    def indirect_ack(target_id)
      @members[target_id].replied_with_ack
    end

    private

    def member(id)
      @members[id] ||= Member.new(id, self)
    end
  end
end