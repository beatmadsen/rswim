# frozen_string_literal: true

require 'socket'

module RSwim
  class Node
    def initialize(my_host, seed_hosts, t_ms, r_ms)
      @my_host = my_host
      @directory = Directory.new
      @my_id = @directory.id(@my_host)
      @deserializer = Integration::Deserializer.new(@directory, @my_id)
      @serializer = Integration::Serializer.new(@directory)
      @pipe = RSwim::Pipe.simple
      seed_ids = seed_hosts.map { |host| @directory.id(host) }
      @agent = RSwim::Agent::SleepBased.new(@pipe, @my_id, seed_ids, t_ms, r_ms)
    end

    def self.udp(my_host, seed_hosts, port, t_ms = T_MS, r_ms = R_MS)
      Integration::Udp::Node.new(my_host, seed_hosts, port, t_ms, r_ms)
    end

    def subscribe(&block)
      @agent.subscribe do |update_entry|
        host = @directory.host(update_entry.member_id)
        block.call(host, update_entry.status, update_entry.custom_state)
      end
    end

    def append_custom_state(key, value)
      @agent.append_custom_state(key, value)
    end

    # blocks until interrupted
    def start
      logger.info 'starting node'
      before_start
      @agent.run
    rescue StandardError => e
      logger.error("Node failed: #{e}")
    end

    protected

    def before_start
      raise 'must be implemented in subclass'
    end

    def logger
      @_logger ||= RSwim::Logger.new(self.class, $stderr)
    end
  end
end
