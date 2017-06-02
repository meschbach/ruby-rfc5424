# MEE::RFC5424

Ruby loggger capable of logging against Syslog (RFC5424) over TCP and Syslog over TLS.  Logs may be in either non-transparent newline framing or octet counting framing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mee-rfc5424'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mee-rfc5424

## Usage

By default the loggers will use transparent octet counting.

### TCP Syslog connection

```ruby
require 'mee/rfc5424'

logger = MEE::RFC5424.tcp( 'syslog.host', 514 )
logger.info { "TCP logging message" }
```

### TLS Syslog connection

```ruby
require 'mee/rfc5424'

logger = MEE::RFC5424.tls( 'syslog.host', 10242 )
logger.info { "TLS message logging" }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/meschbach/mee-rfc5424.

## Licensing

Licensed under the temrs of the MIT license
