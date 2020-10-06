# RSwim

RSwim is a Ruby implementation of the SWIM gossip protocol, a mechanism for discovering new peers and getting updates about liveness of existing peers in a network.

It is an implementation inspired by the original [SWIM: Scalable Weakly-consistent Infection-style Process Group Membership Protocol](https://www.cs.cornell.edu/projects/Quicksilver/public_pdfs/SWIM.pdf) paper by Abhinandan Das, Indranil Gupta, Ashish Motivala.

The implementation is kept intentionally simple and limited to the features described in the paper.
No attempts have been made to address known security issues such as Byzantine attacks.

Currently RSwim runs on UDP with a custom, human readable serialization format.


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

Example:
```ruby
  require 'rswim'

  port = 4545

  # known, running nodes to connect with initially.
  seed_hosts = ['192.168.1.42', '192.168.1.43']

  puts "Starting node"

  # Instantiate node, setting my_host to nil to auto detect host IP.
  node = RSwim::Node.udp(nil, seed_hosts, port)

  # Subscribe to updates
  node.subscribe do |host, status|
    puts "Update: #{host} entered state #{status}"
  end

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
