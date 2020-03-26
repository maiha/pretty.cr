# `Pretty::Df` represents `df(1)` as `Pretty::KB`
#
# ### Usage
#
# ```crystal
# df = Pretty.df("/dev/sda1")
# df.fs        # => "/dev/sda1"
# df.size.gib  # => 77.48989486694336
# df.used.gib  # => 36.44459533691406
# df.avail.gib # => 41.0296745300293
# df.pcent     # => 48
# df.mount     # => "/"
# ```

class Pretty::Df
  getter fs
  getter size
  getter used
  getter avail
  getter pcent
  getter mount

  def initialize(@fs : String, @size : Bytes, @used : Bytes, @avail : Bytes, @pcent : Int32, @mount : String)
  end

  def self.parse(df_output : String)
    unit = nil

    df_output.strip.split(/\n/).each do |line|
      case line
      when /^Filesystem\s+1([KMGTPEZY]B?)-blocks/
        # Filesystem     1K-blocks     Used Available Use% Mounted on
        unit = $1

      else
        # /dev/vda1       81254044 38215048  43022612  48% /
        ary = line.chomp.split(/\s+/)
        fs    = ary.shift? || raise ArgumentError.new("df: no 'Filesystem' found")
        size  = ary.shift? || raise ArgumentError.new("df: no 'Size' found")
        used  = ary.shift? || raise ArgumentError.new("df: no 'Used' found")
        avail = ary.shift? || raise ArgumentError.new("df: no 'Avail' found")
        pcent = ary.shift? || raise ArgumentError.new("df: no 'Used%' found")
        mount = ary.shift? || raise ArgumentError.new("df: no 'Mounted on' found")

        u = unit || raise ArgumentError.new("df: no headers")
        
        size  = Bytes.parse?("#{size}#{u}")  || raise ArgumentError.new("df: 'Size' is not numeric: #{size}")
        used  = Bytes.parse?("#{used}#{u}")  || raise ArgumentError.new("df: 'Used' is not numeric: #{used}")
        avail = Bytes.parse?("#{avail}#{u}") || raise ArgumentError.new("df: 'Avail' is not numeric: #{avail}")
        pcent = pcent.to_s.sub("%","").to_i32? || raise ArgumentError.new("df: 'Pcent' is not numeric: #{pcent}")

        return new(fs, size, used, avail, pcent, mount)
      end
    end

    raise ArgumentError.new("df: no entries")
  end
end

def Pretty.df(fs : String) : Pretty::Df
  proc = Process.new("df", {"-k", fs}, env: {"LC_ALL" => "C"}, output: Process::Redirect::Pipe)
  output = proc.output.gets_to_end
  status = proc.wait
  if status.success?
    Pretty::Df.parse(output)
  else
    raise IO::Error.new("df -k #{fs}")
  end
end
