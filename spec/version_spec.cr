require "./spec_helper"

private macro parse(str, values, build)
  it {{str}} do
    ver = Pretty::Version.parse({{str}})
    ver.values.should eq({{values}})
    ver.build .should eq({{build}})
    ver.to_s  .should eq({{str}})
  end
end

describe Pretty::Version do
  describe ".parse" do
    parse "0.28.0-dev", [0,28,0],"dev"
    parse "0.27.2"    , [0,27,2],""
    parse "1.2.3.4"   , [1,2,3,4],""

    it "raises ArgumentError when invalid format is given" do
      expect_raises(ArgumentError) do
        Pretty::Version.parse("a.b.c")
      end
    end
  end

  it "acts as array" do
    Pretty::Version.parse("0.27.2")[1,2].should eq([27,2])
  end

  it "provides general versioning names" do
    version = Pretty::Version.parse("0.27.2-dev")
    version.major.should eq(0)
    version.minor.should eq(27)
    version.rev  .should eq(2)
    version.build.should eq("dev")
  end

  describe "(usecase: sorting of ip address)" do
    it "can sort" do
      versions = Array(Pretty::Version).new
      versions << Pretty.version("127.0.0.1")
      versions << Pretty.version("10.10.10.1")
      versions << Pretty.version("192.168.0.255")
      versions << Pretty.version("10.10.0.10")
      versions << Pretty.version("10.10.1.13")
      versions << Pretty.version("10.10.0.1")

      versions.sort.map(&.to_s).join("\n").should eq <<-EOF
        10.10.0.1
        10.10.0.10
        10.10.1.13
        10.10.10.1
        127.0.0.1
        192.168.0.255
        EOF
    end
  end
end
