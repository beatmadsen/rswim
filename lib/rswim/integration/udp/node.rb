# frozen_string_literal: true

module RSwim
  module Integration
    module UDP
      # Node implementation that sends and listens using UDP
      class Node < RSwim::Node
        def initialize(my_host, seed_hosts, port, t_ms, r_ms)
          @port = port
          my_host ||= Socket.ip_address_list.find(&:ipv4_private?).ip_address
          super(my_host, seed_hosts, t_ms, r_ms)
        end

        protected

        def create_io_loop
          raise 'bad setup' if @port.nil?
          IOLoop.new(@agent, @serializer, @deserializer, @directory, @sleep_time_seconds, @my_host, @port)
        end
      end
    end
  end
end
