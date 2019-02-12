# `Pretty::MemInfo` provides a handy access to "/proc/meminfo"
# `Pretty.mem_info` provides a shortcut for the current host.
#
# ### Usage
#
# ```crystal
# Pretty.mem_info             # => #<Pretty::MemInfo>
# Pretty.mem_info.keys        # => ["MemTotal", "MemFree", ...]
# Pretty.mem_info["MemTotal"] # => Pretty::UsedMemory(@kb=32939736_i64)
# Pretty.mem_info.total       # => Pretty::UsedMemory(@kb=32939736_i64)
# ```

def Pretty.mem_info : Pretty::MemInfo
  Pretty::MemInfo.host
end

class Pretty::MemInfo
  delegate keys, to: @values

  SHORTCUTS = {
    # special
    "total"              => "MemTotal",
    "free"               => "MemFree",
    "available"          => "MemAvailable",
    "max"                => "VmHWM",
    
    # general
    "mem_total"          => "MemTotal",
    "mem_free"           => "MemFree",
    "mem_available"      => "MemAvailable",
    "buffers"            => "Buffers",
    "cached"             => "Cached",
    "swap_cached"        => "SwapCached",
    "active"             => "Active",
    "inactive"           => "Inactive",
    "active_anon"        => "Active(anon)",
    "inactive_anon"      => "Inactive(anon)",
    "active_file"        => "Active(file)",
    "inactive_file"      => "Inactive(file)",
    "unevictable"        => "Unevictable",
    "mlocked"            => "Mlocked",
    "swap_total"         => "SwapTotal",
    "swap_free"          => "SwapFree",
    "dirty"              => "Dirty",
    "writeback"          => "Writeback",
    "anon_pages"         => "AnonPages",
    "mapped"             => "Mapped",
    "shmem"              => "Shmem",
    "slab"               => "Slab",
    "s_reclaimable"      => "SReclaimable",
    "s_unreclaim"        => "SUnreclaim",
    "kernel_stack"       => "KernelStack",
    "page_tables"        => "PageTables",
    "nfs_unstable"       => "NFS_Unstable",
    "bounce"             => "Bounce",
    "writeback_tmp"      => "WritebackTmp",
    "commit_limit"       => "CommitLimit",
    "committed_as"       => "Committed_AS",
    "vmalloc_total"      => "VmallocTotal",
    "vmalloc_used"       => "VmallocUsed",
    "vmalloc_chunk"      => "VmallocChunk",
    "hardware_corrupted" => "HardwareCorrupted",
    "anon_huge_pages"    => "AnonHugePages",
    "shmem_huge_pages"   => "ShmemHugePages",
    "shmem_pmd_mapped"   => "ShmemPmdMapped",
    "cma_total"          => "CmaTotal",
    "cma_free"           => "CmaFree",
    "hugepagesize"       => "Hugepagesize",
    "direct_map4k"       => "DirectMap4k",
    "direct_map2m"       => "DirectMap2M",
    "direct_map1g"       => "DirectMap1G",
  }

  def initialize(@values : Hash(String, Int64))
  end

  #  MemTotal:       11588840 kB
  def []?(name) : UsedMemory?
    @values[name]?.try{|v| UsedMemory.new(v)}
  end

  def [](name) : UsedMemory
    self[name]? || raise ArgumentError.new("MemInfo[#{name}] not found")
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

class Pretty::MemInfo
  def self.load(path : String) : MemInfo
    parse(File.read(path))
  end

  def self.parse(buffer : String) : MemInfo
    hash = Hash(String, Int64).new
    buffer.scan(/^([^\n]+?):\s+(\d+) kB$/m) do
      hash[$1] = $2.to_i64
    end
    new(hash)
  end

  def self.host : MemInfo
    load("/proc/meminfo")
  end

  def self.process(id : Int32? = nil)
    id = id || "self"
    load("/proc/#{id}/status")
  end
end
