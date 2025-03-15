require "./spec_helper"

private def mem
  Pretty::ProcessInfo.parse <<-EOF
    VmPeak:	    7344 kB
    VmSize:	    7344 kB
    VmLck:	       0 kB
    VmPin:	       0 kB
    VmHWM:	     744 kB
    VmRSS:	     744 kB
    RssAnon:	      64 kB
    RssFile:	     680 kB
    RssShmem:	       0 kB
    VmData:	     312 kB
    VmStk:	     132 kB
    VmExe:	      32 kB
    VmLib:	    2112 kB
    VmPTE:	      60 kB
    VmSwap:	       0 kB
    HugetlbPages:      0 kB
    EOF
end

describe Pretty::ProcessInfo do
  it "provides [](key)" do
    mem["VmPeak"].kb.should eq(7344_i64)
  end

  it "provides keys" do
    mem.keys.should be_a(Array(String))
  end

  describe "(shortcuts)" do
    {% for k, v in Pretty::ProcessInfo::SHORTCUTS %}
      it "provides " + {{k}} do
        mem.{{k.id}}.should eq(mem[{{v}}])
        mem.{{k.id}}?.should eq(mem[{{v}}]?)
      end
    {% end %}
  end

  describe ".max" do
    it "works" do
      Pretty.process_info.max
    end
  end

  describe "(too large number)" do
    invalid_data = <<-EOF
      VmExe:        32 kB
      VmLib: 18446744073709551328 kB
      EOF

    it "raises in default" do
      expect_raises(Exception, /VmLib/) do
        Pretty::ProcessInfo.parse(invalid_data)
      end
    end

    it "skips when skip_invalid" do
      info = Pretty::ProcessInfo.parse(invalid_data, skip_invalid: true)
      info["VmExe"]?.try(&.kb).should eq(32)
      info["VmLib"]?.should eq nil
    end
  end
end
