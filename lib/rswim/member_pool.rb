# frozen_string_literal: true

module RSwim
  class MemberPool
    def initialize(node_member_id, seed_member_ids)
      seed_member_ids -= [node_member_id]
      @node_member_id = node_member_id
      @me = Member::Me.new(node_member_id)
      @members = { node_member_id => @me }
      seed_member_ids.each { |id| member(id) }
      @subscribers = []
    end

    def append_custom_state(key, value)
      @me.append_custom_state(key, value)
    end

    def update_member(message)
      updates = message.payload[:updates]
      incorporate_gossip(updates) unless updates.nil?

      sender = member(message.from) # NB: records member if not seen before
      case message.type
      when :ping
        @me.schedule_ack(message.from)
      when :ack
        sender.replied_with_ack
      when :ping_req
        target_id = message.payload[:target_id]
        member(target_id).ping_from!(message.from)
      else
        raise 'bad message type'
      end
    end

    def update_members(elapsed_seconds)
      @members.values.each { |m| m.update(elapsed_seconds) }
    end

    def status_report
      StatusReport.print(@node_member_id, @members)
    end

    def subscribe(&block)
      @subscribers << block
    end

    def prepare_output
      ms = @members.values.flat_map(&:prepare_output)
      return ms if ms.empty?

      update_entries = @members.map { |_k, member| member.prepare_update_entry }
                               .sort_by(&:propagation_count) # sort ascending!
                               .take(15) # TODO: constant

      update_entries.each do |entry|
        publish(entry) if entry.propagation_count.zero?
        member(entry.member_id).increment_propagation_count
      end

      ms.each { |message| message.payload[:updates] = update_entries }
      ms
    end

    def send_ping_to_random_healthy_member
      ms = @members.values.select(&:can_be_pinged?)
      return if ms.empty?

      member = random_member(ms)
      member.ping!
    end

    def send_ping_request_to_k_members(target_id)
      @members.inject([]) { |acc, (id, m)| id != target_id && m.can_be_pinged? ? (acc << m) : acc }
              .take(K)
              .each { |m| m.ping_request!(target_id) }
    end

    def forward_ack_to(member_id)
      member(member_id).forward_ack
    end

    def halt_member(member_id)
      member(member_id).halt
    end

    def remove_member(member_id)
      raise 'boom' if member_id == @node_member_id

      @members.delete(member_id)
    end

    def member_replied_in_time(member_id)
      member(member_id).replied_in_time
    end

    def member_failed_to_reply(member_id)
      member(member_id).failed_to_reply
    end

    protected

    def random_member(members)
      index = members.one? ? 0 : rand(members.size)
      members[index]
    end

    private

    def publish(update_entry)
      @subscribers.each { |s| s.call(update_entry) }
    end

    def incorporate_gossip(updates)
      updates.each do |u|
        m = member(u.member_id)
        m.incorporate_gossip(u)
      end
    end

    def member(id)
      raise 'boom' if id.nil?

      @members[id] ||= Member::Peer.new(id, @node_member_id, self)
    end
  end
end
