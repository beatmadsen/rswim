# frozen_string_literal: true

module Gossip
  class MemberPool
    def initialize(seed_member_ids)
      @members = {}
      seed_member_ids.each { |id| member(id) }
      @ack_responder = AckResponder.new
    end

    def update_member(message)
      sender = member(message.from) # NB: records member if not seen before
      case message.type
      when :ping
        @ack_responder.schedule_ack(message.from)
      when :ack
        sender.replied_with_ack
      when :ping_req
        target_id = message.payload[:target_id]
        member(target_id).forward_ping(message.from)
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
