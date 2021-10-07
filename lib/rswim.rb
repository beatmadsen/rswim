# frozen_string_literal: true

require 'logger'
require 'socket'
require 'zeitwerk'
require 'async'

# frozen_string_literal: true

class MyInflector < Zeitwerk::Inflector
  def camelize(basename, _abspath)
    case basename
    when 'rswim' then 'RSwim'
    when 'udp' then 'UDP'
    when 'io_loop' then 'IOLoop'
    else super
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector = MyInflector.new
loader.setup

module RSwim
  K = 3

  # Protocol time, millis
  T_MS = 30_000

  # Roundtrip time, millis
  R_MS = 10_000

  class Error < StandardError; end
end
