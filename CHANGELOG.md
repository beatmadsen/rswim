# 1.0.0 Complete implementation for UDP plus simple, human readable serialisation of messages
# 2.0.0 Piggyback custom state on the liveness propagation mechanism using `RSwim::Node#append_custom_state`
# 2.1.0 Use non-blocking I/O by means of `Fiber.shedule` with the scheduler provided by the Async gem
# 2.2.0 Encrypted messages between peers. Run UDP Sender in fiber instead of thread to make whole node single threaded.
# 2.3.0 Runs on current Ruby. `require 'rswim'` failed outright on Ruby 3.4 and later, because base64 and logger left the standard library and were never declared as dependencies. `RSwim::VERSION` was unreachable once the gem was loaded, since the loader expected version.rb to define `RSwim::Version`. Requires Ruby 3.3 or newer and async 2.x. The published gem no longer carries the development scripts, the Rakefile or the Guardfile.
