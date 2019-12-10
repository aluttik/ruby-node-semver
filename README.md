# ruby-node-semver
Ruby version of [node-semver](https://github.com/isaacs/node-semver)


## install

_todo_

## examples

```ruby
require_relative 'node_semver.rb'

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
max_satisfying(versions, '~1.2.3', loose=false, include_prerelease=true) == '1.2.6-pre.1'
max_satisfying(versions, '~1.2.3', loose=false, include_prerelease=false) == '1.2.5'
```
