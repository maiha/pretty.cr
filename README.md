# pretty.cr [![Build Status](https://travis-ci.org/maiha/pretty.cr.svg?branch=master)](https://travis-ci.org/maiha/pretty.cr)

Something `pretty` stuff for [Crystal](http://crystal-lang.org/).

```crystal
Pretty.bytes(123456789)                # => "123 MB"
Pretty.number(123456789)               # => "123,456,789"
Pretty.time("2000-01-02 03:04:05.678") # => 2000-01-02 03:04:05 UTC
Pretty.camelize("http_request")        # => "httpRequest"
Pretty.classify("http_request")        # => "HttpRequest"
Pretty.underscore("a1Id")              # => "a1_id"
Pretty.diff(1,2).to_s                  # => "Expected '1', but got '2'"
Pretty.method(1.5).call("ceil")        # => 2
```

- crystal: 0.24.2

## API

```crystal
Pretty.bytes(value : Int, block = 1000, suffix = "B")
Pretty.camelize(str : String)
Pretty.classify(str : String)
Pretty.error(err : Exception)
Pretty.json(json : String, color : Bool = false)
Pretty.lines(lines : Array(Array(String)), indent : String = "", delimiter : String = "")
Pretty.method(obj : T).call(name : String)
Pretty.number(n : Int)
Pretty.underscore(str : String)
Pretty::Time.parse(value : String)
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pretty:
    github: maiha/pretty.cr
    version: 0.5.6
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

### `Pretty.camelize(str) : String`

```crystal
Pretty.camelize("http_request")     # => "httpRequest"
```

### `Pretty.classify(str) : String`

```crystal
Pretty.classify("http_request")     # => "HttpRequest"
```

### `Pretty.diff(a, b) : Pretty::Diff`

```crystal
data1 = [[112433,15,0],[112465,7293,273]]
data2 = [[112433,15,0],[112465,1307,273]]

diff = Pretty.diff(data1, data2)
diff.size # => 1
diff.to_s # => "Expected '7293', but got '1307'"
```

### `Pretty.error(err) : Pretty::Error`

```crystal
err.backtrace            # => ["0x48df77: *CallStack::unwind:Array(Pointer(Void))
Pretty.error(err).where  # => "mysql at src/commands/db.cr 20:3"
```

##### **IMPORTANT**
- We must call app with **path** for `where`, otherwise the app will be killed.
  - :x: `foo`                # would kill your app in printing backtraces
  - :o: `/usr/local/bin/foo` # will work

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

### `Pretty.method(obj : T).call(name : String)`

invoke method by `String`

```crystal
Pretty.method([1,2]).call("pop")  # => 2
Pretty.method([1,2]).call?("xxx") # => nil
```

##### **NOTE**
- works only public methods, not trailing equals, defined in itself not ancestors

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
