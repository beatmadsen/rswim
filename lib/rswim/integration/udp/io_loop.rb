# frozen_string_literal: true

module RSwim
  module Integration
    module UDP
      class IOLoop < RSwim::IOLoop
        def initialize(agent, serializer, deserializer, directory, sleep_time_seconds, my_host, port)
          super(agent, serializer, deserializer, directory, sleep_time_seconds)
          @my_host = my_host
          @port = port
        end

        protected

        def before_run
          @in_s = UDPSocket.new
          @in_s.bind(@my_host, @port)
          @out_q = Queue.new
          Fiber.schedule { Sender.new(@port, @out_q).run }
        end

        def read
          text, sender = @in_s.recvfrom(10_000)
          [sender[3], text]
        rescue StandardError => e
          logger.debug("Error while receiving: #{e}")
        end

        def send(wire_messages)
          @out_q << wire_messages
        rescue StandardError => e
          logger.debug("Error while sending: #{e}")
        end
      end
    end
  end
end
