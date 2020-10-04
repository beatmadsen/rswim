module Gossip
  module Integration
    module Udp
      class Directory
        def initialize
          @i = 0
          @ids = {}
          @hosts = {}
        end

        def id(host)
          result = @ids[host]
          if result.nil?
            @i += 1
            @ids[host] = @i
            @hosts[@i] = host
            @i
          else
            result
          end
        end

        def host(id)
          @hosts[id]
        end
      end
    end
  end
end
