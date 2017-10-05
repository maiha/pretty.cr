# pretty.cr [![Build Status](https://travis-ci.org/maiha/pretty.cr.svg?branch=master)](https://travis-ci.org/maiha/pretty.cr)

Something `pretty` stuff for [Crystal](http://crystal-lang.org/).

- crystal: 0.23.1

## Features

- `Pretty.lines` : formats `Array(Array(String))` as table-like text.
- `Pretty.json` : formats JSON string

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pretty:
    github: maiha/pretty.cr
    version: 0.2.0
```

## Usage

```crystal
require "pretty"
```

### `lines : String`
- args: `(lines : Array(Array(String)), indent : String = "", delimiter : String = "")`

```crystal
array = [
  ["user", "maiha"],
  ["password", "123"],
]
Pretty.lines(array, delimiter: " = ")
# user     = maiha
# password = 123
```

### `json : String`
- args: `(json : String, color : Bool = false)`

```crystal
json = %({"id": "123", "name": "maiha"})
Pretty.lines(json)
# {
#   "id": "123",
#   "name": "maiha"
# }
```

## Development

```shell
make
```

## Contributing

1. Fork it ( https://github.com/maiha/pretty.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
