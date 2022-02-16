# RSwim

RSwim is a Ruby implementation of the SWIM gossip protocol, a mechanism for discovering new peers and getting updates about liveness of existing peers in a network.

It is an implementation inspired by the original [SWIM: Scalable Weakly-consistent Infection-style Process Group Membership Protocol](https://www.cs.cornell.edu/projects/Quicksilver/public_pdfs/SWIM.pdf) paper by Abhinandan Das, Indranil Gupta, Ashish Motivala.

The implementation is kept intentionally simple and includes only the features described in the paper along with a few additions after version 2.0.0:

- The ability to piggyback custom state on the liveness propagation mechanism was added in version 2.0.0, see `RSwim::Node#append_custom_state`
- Encryption of messsages between peers based on a shared secret was introduced in version 2.2.0, see module `RSwim::Serialization::Encrypted`

No attempts have been made to address known security issues such as Byzantine attacks.

Currently RSwim runs on UDP. In the unencrypted mode it uses a custom, human readable serialization format. Peers in unencrypted mode cannot communicate with peers in encrypted mode.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rswim'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rswim

## Usage
To try out a small demo script, execute `bin/run_node --help` for more information.

Example:
```ruby
  require 'rswim'

  RSwim.encrypted = true
  RSwim.shared_secret = 'santa 2000'

  port = 4545

  # known, running nodes to connect with initially.
  seed_hosts = ['192.168.1.42', '192.168.1.43']

  puts "Starting node"

  # Instantiate node, setting my_host to nil to auto detect host IP.
  node = RSwim::Node.udp(nil, seed_hosts, port)

  # Subscribe to updates
  node.subscribe do |host, status, custom_state|
    puts "Update: #{host} entered liveness state #{status} with custom state #{custom_state}"
  end
  
  # Periodically append new state for publishing
  Thread.new do
    uptime = 0
    loop do
      sleep(5)
      uptime += 5
      node.append_custom_state(:uptime_seconds, uptime)
    end
  end.abort_on_exception = true

  puts "Ready\n"
  begin
    # Run node (blocking)
    node.start
  rescue Interrupt
  end
  puts "\nDone"

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beatmadsen/rswim.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
