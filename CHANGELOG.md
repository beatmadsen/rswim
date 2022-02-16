# 1.0.0 Complete implementation for UDP plus simple, human readable serialisation of messages
# 2.0.0 Piggyback custom state on the liveness propagation mechanism using `RSwim::Node#append_custom_state`
# 2.1.0 Use non-blocking I/O by means of `Fiber.shedule` with the scheduler provided by the Async gem
# 2.2.0 Encrypted messages between peers. Run UDP Sender in fiber instead of thread to make whole node single threaded.