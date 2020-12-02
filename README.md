# RubyNodeSemver

Ruby version of [node-semver](https://github.com/isaacs/node-semver)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_node_semver'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ruby_node_semver

## examples

```ruby
require 'node_semver'

versions = ['1.2.3', '1.2.4', '1.2.5', '1.2.6', '2.0.1']
NodeSemver.max_satisfying(versions, '~1.2.3', loose=false) == "1.2.6"

versions = ['1.1.0', '1.2.0', '1.2.1', '1.3.0', '2.0.0b1', '2.0.0b2', '2.0.0b3', '2.0.0', '2.1.0']
NodeSemver.max_satisfying(versions, '~2.0.0', loose=true) == "2.0.0"

begin
  NodeSemver.max_satisfying(versions, '~2.0.0', loose=false)
rescue
  # raises exception
end

versions = ['1.2.3', '1.2.4', '1.2.5', '1.2.6-pre.1', '2.0.1']
NodeSemver.max_satisfying(versions, '~1.2.3', loose=false, include_prerelease=true) == '1.2.6-pre.1'
NodeSemver.max_satisfying(versions, '~1.2.3', loose=false, include_prerelease=false) == '1.2.5'
```

## Development

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/voodoologic/ruby_node_semver. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/voodoologic/ruby_node_semver/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubyNodeSemver project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/voodoologic/ruby_node_semver/blob/master/CODE_OF_CONDUCT.md).
