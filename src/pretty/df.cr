# `Pretty::Df` represents `df(1)` as `Pretty::KB`
# `inode` option enables `df -i`.
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
# df.cmd       # => "LC_ALL=C df -k /dev/sda1"
#
# df = Pretty.df("/dev/sda1", inode: true)
# ```

class Pretty::Df
  getter fs
  getter size
  getter used
  getter avail
  getter pcent
  getter mount
  getter cmd

  def initialize(@fs : String, @size : Bytes, @used : Bytes, @avail : Bytes, @pcent : Int32, @mount : String, @cmd : String)
  end

  # alias: `avail` is represented as `free` in inode context.
  def free
    avail
  end

  def self.parse(df_output : String, cmd : String = "")
    unit = nil

    # [df_output](df -k /)
    # ```
    # Filesystem     1K-blocks     Used Available Use% Mounted on
    # /dev/vda1       81254044 38273664  42963996  48% /
    # ```
    #
    # [df_output](df -k -i /)
    # ```
    # Filesystem       Inodes  IUsed   IFree IUse% Mounted on
    # /dev/vda1      10240000 606344 9633656    6% /
    # ```

    # The number of lines should be at least 2.
    lines = df_output.strip.split(/\n/)

    ### For the first line (aka. header)
    line = lines.shift? || raise ArgumentError.new("df: no header lines")

    case line
    when /^Filesystem\s+1([KMGTPEZY]B?)-blocks/
      # (df -k) "Filesystem     1K-blocks     Used Available Use% Mounted on"
      # puts "K" into `unit` var.
      unit = $1
    when /^Filesystem\s/
      # (df -i) "Filesystem       Inodes  IUsed   IFree IUse% Mounted on"
      # puts "" into `unit` var. (no units mark)
      unit = ""
    else
      # Otherwise, give up.
      raise ArgumentError.new("df: cannot parse header: #{line.inspect}")
    end

    ### For the second line (aka. data)
    line = lines.shift? || raise ArgumentError.new("df: no data lines")

    # (df      ) "/dev/vda1       78G       37G       41G  48%  /"
    # (df -k   ) "/dev/vda1  81254044  38273664  42963996  48%  /"
    # (df -i   ) "/dev/vda1      9.8M      593K      9.2M   6%  /"
    # (df -i -k) "/dev/vda1  10240000    606344   9633656   6%  /"

    ary = line.chomp.split(/\s+/)
    fs    = ary.shift? || raise ArgumentError.new("df: no 'Filesystem' found")
    size  = ary.shift? || raise ArgumentError.new("df: no 'Size' found")
    used  = ary.shift? || raise ArgumentError.new("df: no 'Used' found")
    avail = ary.shift? || raise ArgumentError.new("df: no 'Avail' found")
    pcent = ary.shift? || raise ArgumentError.new("df: no 'Used%' found")
    mount = ary.shift? || raise ArgumentError.new("df: no 'Mounted on' found")

    u = unit || raise ArgumentError.new("df: no units [BUG]")
    size  = Bytes.parse?("#{size}#{u}")  || raise ArgumentError.new("df: 'Size' is not numeric: #{size}")
    used  = Bytes.parse?("#{used}#{u}")  || raise ArgumentError.new("df: 'Used' is not numeric: #{used}")
    avail = Bytes.parse?("#{avail}#{u}") || raise ArgumentError.new("df: 'Avail' is not numeric: #{avail}")
    pcent = pcent.to_s.sub("%","").to_i32? || raise ArgumentError.new("df: 'Pcent' is not numeric: #{pcent}")
    return new(fs, size, used, avail, pcent, mount, cmd)
  end
end

def Pretty.df(fs : String, inode : Bool = false) : Pretty::Df
  env = {"LC_ALL" => "C"}
  args = ["-k", fs]
  args << "-i" if inode
  proc = Process.new("df", args, env: env, output: Process::Redirect::Pipe)
  output = proc.output.gets_to_end
  status = proc.wait
  if status.success?
    cmd = (env.map(&.join("=")) + ["df"] + args).join(" ")
    Pretty::Df.parse(output, cmd)
  else
    raise IO::Error.new("df -k #{fs}")
  end
end
