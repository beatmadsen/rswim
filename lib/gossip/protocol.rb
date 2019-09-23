module Gossip
  class Protocol
    def initialize(pipe)
      @pipe = pipe
      @members = {}
      @ack_responder = AckResponder.new
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
        x = @members.values
        x << @ack_responder
        output = x.flat_map(&:prepare_output)
        output.each { |ary| @pipe.send(ary) }
        sleep 0.1 if output.empty? && input.nil?
      end
    end

    private

    def update_member(input)
      member_id, message = input
      message.strip!
      @ack_responder.schedule_ack(member_id) if message == 'ping'
      @members[member_id] ||= Member.new(member_id)
    end

    def update_members(elapsed_seconds)
      @members.values.each { |m| m.update(elapsed_seconds) }
    end
  end
end
