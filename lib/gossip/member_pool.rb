# frozen_string_literal: true

module Gossip
  class MemberPool
    def initialize(node_member_id, seed_member_ids)
      seed_member_ids = seed_member_ids - [node_member_id]
      @node_member_id = node_member_id
      @me = Member::Me.new(node_member_id)
      @members = { node_member_id: @me }
      seed_member_ids.each { |id| member(id) }
    end

    def update_member(message)
      sender = member(message.from) # NB: records member if not seen before
      case message.type
      when :ping
        @me.schedule_ack(message.from)
      when :ack
        sender.replied_with_ack
      when :ping_req
        target_id = message.payload[:target_id]
        member(target_id).forward_ping(message.from)
      end
      update_suspicions(message.payload[:updates])
    end

    def update_members(elapsed_seconds)
      @members.values.each { |m| m.update(elapsed_seconds) }
    end

    def status_report
      StatusReport.print(@members)
    end

    def prepare_output
      update_entries = @members.map { |_k, member| member.prepare_update_entry }
                               .sort_by { |entry| 100 - entry.propagation_count }
                               .take(10) # TODO: constant

      update_entries.each { |u| member(u.member_id).increment_propagation_count }

      ms = @members.values.flat_map(&:prepare_output)
      ms.each { |message| message.payload[:updates] = update_entries }
      ms
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

    def update_suspicions(updates)
      updates.each do |u|
        member(u.member_id).update_suspicion(u.status, u.incarnation_number)
      end
    end

    def member(id)
      @members[id] ||= Member::Peer.new(id, @node_member_id, self)
    end
  end
end
