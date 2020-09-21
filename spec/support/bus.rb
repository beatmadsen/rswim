class Bus

  class AetherQueue
    def initialize()
      @queues = Hash.new { |hash, key| hash[key] = [] }
    end

    def <<(line)
      member, message = line
      @queues[member] << [@name, message]
    end

    def pop(_flag = false)
      lines = @queues[@name]
      @queues[@name] = []
      lines
    end
  end

end
