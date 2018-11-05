# pretty.cr [![Build Status](https://travis-ci.org/maiha/pretty.cr.svg?branch=master)](https://travis-ci.org/maiha/pretty.cr)

Something `pretty` stuff for [Crystal](http://crystal-lang.org/).

```crystal
Pretty.bytes(123456789)                # => "123 MB"
Pretty.number(123456789)               # => "123,456,789"
Pretty.date("2001-02-03")              # => 2001-02-03 00:00:00.0 Local
Pretty.time("2000-01-02 03:04:05.678") # => 2000-01-02 03:04:05 UTC
Pretty.camelize("http_request")        # => "httpRequest"
Pretty.classify("http_request")        # => "HttpRequest"
Pretty.underscore("a1Id")              # => "a1_id"
Pretty.diff(1,2).to_s                  # => "Expected '1', but got '2'"
Pretty.mem_info.total.gb               # => 32.939736
Pretty.method(1.5).call("ceil")        # => 2
Pretty.process_info.max.mb             # => 3.568
Pretty::Dir.clean("a/b/c")             # rm -rf a/b/c && mkdir -p a/b/c
Pretty::Stopwatch.new                  # provides Stopwatch
klass A < B                            # class A < B; end
```

#### crystal versions
- v0.5.7 for crystal-0.24 or lower
- v0.6.x for crystal-0.25, 0.26, 0.27 or higher

## API

```crystal
Pretty.bytes(value : Int, block = 1000, suffix = "B")
Pretty.camelize(str : String)
Pretty.classify(str : String)
Pretty.date(value : String)
Pretty.error(err : Exception)
Pretty.json(json : String, color : Bool = false)
Pretty.lines(lines : Array(Array(String)), indent : String = "", delimiter : String = "")
Pretty.mem_info
Pretty.method(obj : T).call(name : String)
Pretty.number(n : Int)
Pretty.underscore(str : String)
Pretty::Dir.clean(path : String)
Pretty::Stopwatch.new
Pretty::Time.parse(value : String)
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pretty:
    github: maiha/pretty.cr
    version: 0.6.5
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

### `Pretty.date : Time` (aka. `Pretty::Date.parse(args)`)

```crystal
Pretty.date("2001-02-03") # => 2001-02-03 00:00:00.0 Local
Pretty.date("1 day ago")  # => 2018-09-08 00:00:00.0 +09:00 Local
```

### `Pretty.dates : Array(Time)` (aka. `Pretty::Date.parse_dates(args)`)

```crystal
Pretty.dates("20180901")           # => [Time(20180901)]
Pretty.dates("20180908-20180909")  # => [Time(20180908),Time(20180909)]
Pretty.dates("201809").size        # => 30
Pretty.dates("201801-201802").size # => 59
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

### `Pretty.mem_info : Pretty::MemInfo`

represents memory information in "/proc/meminfo" as `Pretty::MemInfo`

```crystal
Pretty.mem_info             # => #<Pretty::MemInfo>
Pretty.mem_info.keys        # => ["MemTotal", "MemFree", ...]
Pretty.mem_info["MemTotal"] # => Pretty::UsedMemory(@kb=32939736_i64)
Pretty.mem_info.total       # => Pretty::UsedMemory(@kb=32939736_i64)
Pretty.mem_info.total.gb    # => 32.939736
```

### `Pretty.method(obj : T).call(name : String)`

invoke method by `String`

```crystal
Pretty.method([1,2]).call("pop")  # => 2
Pretty.method([1,2]).call?("xxx") # => nil
```

##### **NOTE**
- works only public methods, not trailing equals, defined in itself not ancestors

### `Pretty.process_info(pid = "self") : Pretty::ProcessInfo`

represents memory information in "/proc/*/status" as `Pretty::MemInfo`

```crystal
Pretty.process_info           # => #<Pretty::ProcessInfo>
Pretty.process_info.keys      # => ["VmPeak", "VmSize", ...]
Pretty.process_info["VmPeak"] # => Pretty::UsedMemory(@kb=92644_i64)
Pretty.process_info.max.mb    # => 3.568
Pretty.process_info(1234)     # Error opening file '/proc/1234/status'
```

### `Pretty.number(n) : String`

```crystal
Pretty.number(1000000)  # => "1,000,000"
```

### `Pretty::Dir.clean(dir)`

acts same as unix command `rm -rf dir && mkdir -p dir`.

```crystal
Pretty::Dir.clean("tmp/work")
```

### `Pretty::Time.parse(args) : Time` (aka. `Pretty.time`)

parses time without format!

```crystal
Pretty.time("2000-01-02")                    # => 2000-01-02 00:00:00 UTC
Pretty.time("2000-01-02 03:04:05")           # => 2000-01-02 03:04:05 UTC
Pretty.time("2000-01-02 03:04:05.678")       # => 2000-01-02 03:04:05 UTC
Pretty.time("2000-01-02T03:04:05.678+09:00") # => 2000-01-02 03:04:05 +0900
```

### `klass(name, *properties)` macro

`klass` macro provides end-less class definition.

```crystal
class NotFound < Exception
  getter name

  def initialize(@name : String)
  end
end
```

This can be shortened as follows.

```crystal
klass NotFound < Exception, name : String
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
