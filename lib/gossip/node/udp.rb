# frozen_string_literal: true

require 'socket'

module Gossip
  module Node
    class Udp
      def initialize(port)
        @port = port
        @started = false
      end

      def start
        if @started
          logger.info "already started"
        else
          logger.info "starting node"
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
        logger.info "node was stopped"
      rescue StandardError => e
        logger.debug("Error: #{e}")
      end

      protected

      def logger
        @_logger ||= begin
          Gossip::Logger.new(self.class, STDERR)
        end
      end

      private

      def listen
        begin
          loop do
            logger.debug "about to recieve"
            text, sender = @s.recvfrom(1024)
            logger.info "received #{text} from #{sender}"
          end
        rescue StandardError => e
          logger.debug("Error: #{e}")
        end
        logger.info "node no longer listening"
      end
    end
  end
end
