require "./spec_helper"

private def mem
  Pretty::MemInfo.parse <<-EOF
    MemTotal:       32939736 kB
    MemFree:         4996376 kB
    MemAvailable:   29223028 kB
    Buffers:          979972 kB
    Cached:         22081060 kB
    SwapCached:            0 kB
    Active:         16703568 kB
    Inactive:        9794340 kB
    Active(anon):    2959428 kB
    Inactive(anon):    18392 kB
    Active(file):   13744140 kB
    Inactive(file):  9775948 kB
    Unevictable:        5408 kB
    Mlocked:            5408 kB
    SwapTotal:             0 kB
    SwapFree:              0 kB
    Dirty:              1188 kB
    Writeback:             0 kB
    AnonPages:       3442240 kB
    Mapped:           348612 kB
    Shmem:             18960 kB
    Slab:            1312760 kB
    SReclaimable:    1173260 kB
    SUnreclaim:       139500 kB
    KernelStack:        8256 kB
    PageTables:        30100 kB
    NFS_Unstable:          0 kB
    Bounce:                0 kB
    WritebackTmp:          0 kB
    CommitLimit:    16469868 kB
    Committed_AS:    7388980 kB
    VmallocTotal:   34359738367 kB
    VmallocUsed:           0 kB
    VmallocChunk:          0 kB
    HardwareCorrupted:     0 kB
    AnonHugePages:         0 kB
    ShmemHugePages:        0 kB
    ShmemPmdMapped:        0 kB
    CmaTotal:              0 kB
    CmaFree:               0 kB
    HugePages_Total:       0
    HugePages_Free:        0
    HugePages_Rsvd:        0
    HugePages_Surp:        0
    Hugepagesize:       2048 kB
    DirectMap4k:      237416 kB
    DirectMap2M:    17588224 kB
    DirectMap1G:    17825792 kB

    VmPeak:    10016 kB
    VmSize:    10016 kB
    VmLck:         0 kB
    VmPin:         0 kB
    VmHWM:       984 kB
    VmRSS:       984 kB
    EOF
end

describe Pretty::MemInfo do
  it "provides [](key)" do
    mem["MemTotal"].kb.should eq(32939736)
  end

  describe "(shortcuts)" do
    {% for k,v in Pretty::MemInfo::SHORTCUTS %}
      it "provides " + {{k}} do
        mem.{{k.id}}.should eq(mem[{{v}}])
        mem.{{k.id}}?.should eq(mem[{{v}}]?)
      end
    {% end %}
  end

  describe ".process" do
    it "returns a MemInfo of current process" do
      Pretty::MemInfo.process.max.gb.should be_a(Float64)
    end
  end
end
