module Gossip
  class Protocol
    def initialize(pipe)
      @pipe = pipe
      @members = {}
      @ack_responder = AckResponder.new
    end

    def run
      n = 0
      t = Time.now
      loop do
        inputs = @pipe.receive
        inputs.each do |input|
          update_member(input)
        end

        t_old = t
        t = Time.now
        delta = t - t_old
        update_members(delta)

        # output
        x = @members.values
        x << @ack_responder
        # puts "### DEBUG x: #{x}" if x.size > 1
        output = x.flat_map(&:prepare_output)
        output.each { |ary| @pipe.send(ary) }

        n += 1
        ping_member if n % 1000 == 0 # TODO: protocol period
        print_report if n % 2000 == 0

        sleep 0.010 # 10 ms
      end
    end

    private

    def ping_member
      ms = @members.values.select { |m| m.healthy? }
      return if ms.empty?
      index = ms.one? ? 0 : rand(ms.size)
      member = ms[index]
      member.ping
    end

    def print_report
      a = <<~REPORT

        ====================================
         Status report:
        ====================================

      REPORT
      b = @members.map { |k, m| "#{k}: #{m.health}\n" }.join
      puts a + b
    end

    def update_member(input)
      member_id, message = input
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
