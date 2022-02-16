# frozen_string_literal: true

module RSwim
  class Node
    def self.udp(my_host, seed_hosts, port, t_ms = T_MS, r_ms = R_MS)
      Integration::UDP::Node.new(my_host, seed_hosts, port, t_ms, r_ms)
    end

    def initialize(my_host, seed_hosts, t_ms, r_ms)
      RSwim.validate_config!
      @my_host = my_host
      @directory = Directory.new
      @my_id = @directory.id(@my_host)
      serialization = RSwim.encrypted ? Serialization::Encrypted : Serialization::Simple
      @deserializer = serialization::Deserializer.new(@directory, @my_id)
      @serializer = serialization::Serializer.new(@directory)
      @seed_ids = seed_hosts.map { |host| @directory.id(host) }
      @t_ms = t_ms
      @r_ms = r_ms
      @agent = RSwim::Agent::PushBased.new(@my_id, @seed_ids, t_ms, r_ms)
      @sleep_time_seconds = r_ms / 1_000
      @io_loop = create_io_loop
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

    def start
      logger.info 'starting node'
      @agent.run
      @io_loop.run
    rescue StandardError => e
      logger.error("Node failed: #{e}")
    end

    protected

    def create_io_loop
      raise 'must be implemented in subclass'
    end

    def logger
      @_logger ||= RSwim::Logger.new(self.class, $stderr)
    end
  end
end
