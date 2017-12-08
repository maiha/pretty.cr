# pretty.cr [![Build Status](https://travis-ci.org/maiha/pretty.cr.svg?branch=master)](https://travis-ci.org/maiha/pretty.cr)

Something `pretty` stuff for [Crystal](http://crystal-lang.org/).

```crystal
Pretty.bytes(123456789)                # => "123 MB"
Pretty.number(123456789)               # => "123,456,789"
Pretty.time("2000-01-02 03:04:05.678") # => 2000-01-02 03:04:05 UTC
```

- crystal: 0.23.1

## API

```crystal
Pretty.bytes(value : Int, block = 1000, suffix = "B")
Pretty.error(err : Exception)
Pretty.json(json : String, color : Bool = false)
Pretty.lines(lines : Array(Array(String)), indent : String = "", delimiter : String = "")
Pretty.number(n : Int)
Pretty::Time.parse(value : String)
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pretty:
    github: maiha/pretty.cr
    version: 0.5.1
```

Then require it in your app.
```crystal
require "pretty"
```

## Usage

### `Pretty.bytes(args) : String`

```crystal
Pretty.bytes(416)                   # => "416 B"
Pretty.bytes(12255736)              # => "12.3 MB"
Pretty.bytes(12255736, block: 1024) # => "11.7 MiB"
```

### `Pretty.error(err) : Pretty::Error`

```crystal
err.backtrace            # => ["0x48df77: *CallStack::unwind:Array(Pointer(Void))
Pretty.error(err).where  # => "foo at spec/error_spec.cr 5:5"
```

### `Pretty.json(args) : String`

```crystal
str = %({"id": "123", "name": "maiha"})
Pretty.json(str)
```

```json
{
  "id": "123",
  "name": "maiha"
}
```

### `Pretty.lines(args) : String`

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

### `Pretty.number(n) : String`

```crystal
Pretty.number(1000000)  # => "1,000,000"
```

### `Pretty::Time.parse(args) : Time` (aka. `Pretty.time`)

parses time without format!

```crystal
Pretty.time("2000-01-02")                    # => 2000-01-02 00:00:00 UTC
Pretty.time("2000-01-02 03:04:05")           # => 2000-01-02 03:04:05 UTC
Pretty.time("2000-01-02 03:04:05.678")       # => 2000-01-02 03:04:05 UTC
Pretty.time("2000-01-02T03:04:05.678+09:00") # => 2000-01-02 03:04:05 +0900
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
