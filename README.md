# pretty.cr [![Build Status](https://travis-ci.org/maiha/pretty.cr.svg?branch=master)](https://travis-ci.org/maiha/pretty.cr)

Something `pretty` stuff for [Crystal](http://crystal-lang.org/).

- crystal: 0.23.1

## API

```crystal
Pretty.lines(lines : Array(Array(String)), indent : String = "", delimiter : String = "")
Pretty.json(json : String, color : Bool = false)
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pretty:
    github: maiha/pretty.cr
    version: 0.2.0
```

Then require it in your app.
```crystal
require "pretty"
```

## Usage

#### `Pretty.lines(args) : String`

```crystal
array = [
  ["user", "maiha"],
  ["password", "123"],
]
Pretty.lines(array, delimiter: " = ")
```

```
user     = maiha
password = 123
```

#### `Pretty.json(args) : String`

```crystal
str = %({"id": "123", "name": "maiha"})
Pretty.json(str)
```

```
{
  "id": "123",
  "name": "maiha"
}
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
