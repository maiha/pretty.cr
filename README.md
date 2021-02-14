# pretty.cr [![Build Status](https://travis-ci.org/maiha/pretty.cr.svg?branch=master)](https://travis-ci.org/maiha/pretty.cr)

Something **attentive**, **conservative** and **pretty** stuff with zero dependencies.
* **tested crystal versions** : See [.travis.yml](./.travis.yml)

Since Crystal breaks backward compatibility casually, we need to pay the follow-up cost for every version upgrade. For example, 
* `Time.now` doesn't exist in recent versions, but `Pretty.now` works on all versions.
* `File.expand_path` doesn't expand '~' in default in recent versions, but `Pretty.expand_path` works the same for all versions.

```crystal
Pretty.bar(83,100,width: 20).bar       # => "||||||||||||||||    "
Pretty.bytes(123456789).to_s           # => "123 MB"
Pretty.bytes("12.3GiB").mb             # => 13207.024435
Pretty.kb(123456789).to_s              # => "123GB"
Pretty.kib(123456789).to_s             # => "117GiB"
Pretty.df("/").pcent                   # => 48
Pretty.df("/", inode: true).cmd        # => "LC_ALL=C df -k / -i"
Pretty.number(123456789)               # => "123,456,789"
Pretty.date("2001-02-03")              # => 2001-02-03 00:00:00.0 Local
Pretty.time("2000-01-02 03:04:05.678") # => 2000-01-02 03:04:05 UTC
Pretty.local_time("2000-01-02")        # => 2000-01-02 00:00:00.0 +09:00 Local
Pretty.epoch(981173106)                # => 2001-02-03 04:05:06 UTC
Pretty.camelize("http_request")        # => "httpRequest"
Pretty.classify("http_request")        # => "HttpRequest"
Pretty.underscore("a1Id")              # => "a1_id"
Pretty.diff(1,2).to_s                  # => "Expected '1', but got '2'"
Pretty.expand_path("~/")               # => "/home/ubuntu"
Pretty.mem_info.total.gb               # => 32.939736
Pretty.method(1.5).call("ceil")        # => 2
Pretty.now(2000,1,2,3,4,5)             # => 2000-01-02 03:04:05 (Local)
Pretty.utc(2000,1,2,3,4,5)             # => 2000-01-02 03:04:05 (UTC)
Pretty.periodical(3.seconds)           # => #<Pretty::Periodical::Executor>
Pretty.process_info.max.mb             # => 3.568
Pretty.remove_ansi("foo\e\[0m")        # => "foo"
Pretty.string_width("aあ")             # => 3
Pretty.version("0.28.0-dev").minor     # => 28
Pretty::Crystal.version.minor          # => 27
Pretty::Dir.clean("a/b/c")             # rm -rf a/b/c && mkdir -p a/b/c
Pretty::Logger.new                     # provides composite logger
Pretty::Stopwatch.new                  # provides Stopwatch
Pretty::URI.escape("%")                # => "%25"
Pretty::URI.unescape("%25")            # => "%"

Pretty::Crontab.parse("*/20 * * * * ls").next_time # => "2019-04-18 08:00"

# handy linux file operations
include Pretty::File  # provides unix file commands via `FileUtil`
rm_f("foo.txt") # cd, cmp, touch, cp, cp_r, ln, ln_s, ln_sf, mkdir, mkdir_p, mtime, mv, pwd, rm, rm_r, rm_rf, rmdir
```

#### stdlib pollution
- `Logger` is extended. See [src/pretty/logger/logger.cr](./src/pretty/logger/logger.cr) for details.

#### old crystal
- use v0.5.7 for crystal-0.24 or lower

#### breaking changes
- v0.9.6: `Pretty.bytes` returns `Pretty::Bytes` rather than `String` (use `to_s` for backward compats)
- v0.7.4: `Pretty.now` returns Local rather than UTC
- v0.7.0: drop `klass` macro (Do not define unnecessary macros at the top level)

## API

```crystal
Pretty.bar(val, max, width, mark, empty)
Pretty.bytes(value : Int, block = 1000, suffix = "B")
Pretty.camelize(str : String)
Pretty.classify(str : String)
Pretty.date(value : String)
Pretty.error(err : Exception)
Pretty.gb(value : Int)
Pretty.gib(value : Int)
Pretty.json(json : String, color : Bool = false)
Pretty.kb(value : Int)
Pretty.kib(value : Int)
Pretty.lines(lines : Array(Array(String)), headers : Array(String)? = nil, indent : String = "", delimiter : String = "")
Pretty.mem_info
Pretty.method(obj : T).call(name : String)
Pretty.mb(value : Int)
Pretty.mib(value : Int)
Pretty.number(n : Int)
Pretty.periodical(interval : Time::Span)
Pretty.underscore(str : String)
Pretty::Dir.clean(path : String)
Pretty::Stopwatch.new
Pretty::Time.parse(value : String)
Pretty::URI.escape(path : String, *args, **opts)
Pretty::URI.unescape(path : String, *args, **opts)
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pretty:
    github: maiha/pretty.cr
    version: 1.0.0
```

Then require it in your app.
```crystal
require "pretty"
```

## Usage

### `Pretty.bar(val, max, width, mark, empty)`

```crystal
vals = [8793, 6917, 5534, 8720]
vals.each do |v|
  Pretty.bar(v, max: 10000, width: 20)
end
```

```
[|||||||||||||||||   ]  8793/10000 ( 87%)
[|||||||||||||       ]  6917/10000 ( 69%)
[|||||||||||         ]  5534/10000 ( 55%)
[|||||||||||||||||   ]  8720/10000 ( 87%)
```

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

### `Pretty.epoch(str) : Time`

Absorbs the API difference that changes with each release of crystal.
Personally, `epoch` and `epoch_ms` are the most intuitive.

```crystal
Pretty.epoch(981173106)       # => 2001-02-03 04:05:06 UTC
Pretty.epoch_ms(981173106789) # => 2001-02-03 04:05:06.789 UTC
```

Users can always use this API even if crystal API will be changed again in the future.

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

`Pretty::MemInfo.process` returns a `MemInfo` of current process.
```crystal
logger.info "max memory: %s GB" % Pretty::MemInfo.process.max.gb
```

### `Pretty.method(obj : T).call(name : String)`

invoke method by `String`

```crystal
Pretty.method([1,2]).call("pop")  # => 2
Pretty.method([1,2]).call?("xxx") # => nil
```

##### **NOTE**
- works only public methods, not trailing equals, defined in itself not ancestors

### `Pretty.periodical(interval) : Pretty::Periodical::Executor`

This ensures that it is executed only once within the specified time.
This is useful if you want to write logs regularly.

```crystal
ctx = Pretty.periodical(3.seconds)
10000.times do |i|
  ...
  ctx.execute { logger.info "#{i} done" } # This will be executed once every 3 seconds.
end	
```

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

### `Pretty.version(str) : Pretty::Version`

parses numbers separated by dots.

```crystal
Pretty.version("0.27.2").minor # => 27
```

This can also sort ip addresses.

```crystal
hosts  = %w( 192.168.10.1 192.168.0.255 )
sorted = hosts.map{|s| Pretty.version(s)}.sort
sorted.map(&.to_s) # => ["192.168.0.255", "192.168.10.1"]
sorted.map(&.last) # => [255, 1]
```

### `Pretty::Dir.clean(dir)`

acts same as unix command `rm -rf dir && mkdir -p dir`.

```crystal
Pretty::Dir.clean("tmp/work")
```

### `Pretty::Logger`

Port from [CompositeLogger](https://github.com/maiha/composite_logger.cr).
See above page for details.

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
