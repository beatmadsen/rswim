# frozen_string_literal: true

require 'socket'

module Gossip
  module Integration
    module Udp
      class Node < Gossip::Node
        def initialize(my_host, port)
          super(my_host)
          @port = port
          @started = false
        end

        def start
          if @started
            logger.info 'already started'
          else
            logger.info 'starting node'
            @started = true
            @s = UDPSocket.new
            @s.bind(nil, @port)
            logger.info "node listening on UDP port #{@port}"
            @t = Thread.new { listen }
            @t.abort_on_exception = true
          end
        rescue StandardError => e
          logger.debug("Error: #{e}")
        end

        def stop
          return unless @started

          @t.kill
          @s.close
          @started = false
          logger.info 'node was stopped'
        rescue StandardError => e
          logger.debug("Error: #{e}")
        end

        private

        def listen
          begin
            loop do
              logger.debug 'about to recieve'
              text, sender = @s.recvfrom(10_000)

              message = @deserializer.deserialize(sender[3], text)
              logger.debug "received message of type #{message.type} with #{message.payload[:updates]&.size.to_i} updates"

              #  TODO: we would never reply, instead we would send to standard port at host
              # assuming the other peer is listening too.
              @s.send("ok\n", 0, sender[3], sender[1])
            end
          rescue StandardError => e
            logger.debug("Error: #{e}")
          end
          logger.info 'node no longer listening'
        end
      end
    end
  end
end
