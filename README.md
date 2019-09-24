# BitVector::Hours

[![Actions Status](https://github.com/sdrew/bitvector-hours/workflows/Ruby/badge.svg)](https://github.com/sdrew/bitvector-hours) [![codecov](https://codecov.io/gh/sdrew/bitvector-hours/branch/master/graph/badge.svg)](https://codecov.io/gh/sdrew/bitvector-hours)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitvector-hours'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitvector-hours

## Usage

```ruby
# Empty vector with default resolution of 5mins
bv = BitVector::Hours.new
bv.resolution
#> 5
bv.size
#> 288

bv.expand 10..20
#> [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]

bv.ranges
#> [10...21]

bv.hours
#> [["00:50", "01:45"]]

bv.expand 40...60
bv.ranges
#> [10...21, 40...60]
bv.hours
#> [["00:50", "01:45"], ["03:20", "05:00"]]

bv.clear 50...60
bv.ranges
#> [10...21, 40...50]
bv.hours
#> [["00:50", "01:45"], ["03:20", "04:10"]]

bv.vector[0] = 1
bv.ranges
#> [0...1, 10...21, 40...50]
bv.hours
#> [["00:00", "00:05"], ["00:50", "01:45"], ["03:20", "04:10"]]

bv.active?

bv.active? bit: 10
#> true
bv.active? bit: 100
#> false

bv.active? hour: "04:00"
#> true
bv.active? hour: "23:15"
#> false

bv.to_s
#> "00000000-00000000-00000000-00000000-00000000-00000000-00000000-0003ff00-001ffc01"
```

### Timezones

```ruby
bv.expand ["20:30", "21:00"]

bv.current_hour
#> "22:50"
bv.current_bit
#> 274
bv.active?
#> false

bv.timezone = 'America/Los_Angeles'
bv.current_hour
#> "20:50"
bv.current_bit
#> 250
bv.active?
#> true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sdrew/bitvector-hours. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bitvector::Hours project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sdrew/bitvector-hours/blob/master/CODE_OF_CONDUCT.md).
