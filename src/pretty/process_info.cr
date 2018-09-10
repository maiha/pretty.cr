# `Pretty::ProcessInfo` provides a handy access to the "/proc/*/status"
# `Pretty.process_info` provides a shortcut for the current process.
#
# ### Usage
#
# ```crystal
# Pretty.process_info           # => #<Pretty::ProcessInfo>
# Pretty.process_info.keys      # => ["VmPeak", "VmSize", ...]
# Pretty.process_info["VmPeak"] # => Pretty::UsedMemory(@kb=92644_i64)
# Pretty.process_info.max.mb    # => 3.568
# Pretty.process_info(1234)     # Error opening file '/proc/1234/status'
# ```

def Pretty.process_info(pid : Int32? = nil) : Pretty::ProcessInfo
  Pretty::ProcessInfo.process(pid)
end

class Pretty::ProcessInfo
  delegate keys, to: @values

  SHORTCUTS = {
    # special
    "max"           => "VmHWM",
    "peak"          => "VmPeak",
    # general
    "vm_peak"       => "VmPeak",
    "vm_size"       => "VmSize",
    "vm_lck"        => "VmLck",
    "vm_pin"        => "VmPin",
    "vm_hwm"        => "VmHWM",
    "vm_rss"        => "VmRSS",
    "rss_anon"      => "RssAnon",
    "rss_file"      => "RssFile",
    "rss_shmem"     => "RssShmem",
    "vm_data"       => "VmData",
    "vm_stk"        => "VmStk",
    "vm_exe"        => "VmExe",
    "vm_lib"        => "VmLib",
    "vm_pte"        => "VmPTE",
    "vm_swap"       => "VmSwap",
    "hugetlb_pages" => "HugetlbPages",
  }

  def initialize(@values : Hash(String, Int64))
  end

  # VmPeak:	    7344 kB
  def []?(name) : UsedMemory?
    @values[name]?.try{|v| UsedMemory.new(v)}
  end

  def [](name) : UsedMemory
    self[name]? || raise ArgumentError.new("ProcessInfo[#{name}] not found")
  end

  {% for k,v in SHORTCUTS %}
    def {{k.id}}
      self[{{v}}]
    end

    def {{k.id}}?
      self[{{v}}]?
    end
  {% end %}
end

class Pretty::ProcessInfo
  def self.load(path : String) : ProcessInfo
    parse(File.read(path))
  end

  def self.parse(buffer : String) : ProcessInfo
    hash = Hash(String, Int64).new
    buffer.scan(/^([^\n]+?):\s+(\d+) kB$/m) do
      hash[$1] = $2.to_i64
    end
    new(hash)
  end

  def self.process(pid : Int32? = nil) : ProcessInfo
    pid ||= "self"
    load("/proc/#{pid}/status")
  end
end
