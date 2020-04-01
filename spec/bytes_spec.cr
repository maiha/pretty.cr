require "./spec_helper"

######################################################################
### backward compatibility

describe "Pretty.bytes" do
  it "(with numeric)" do
    Pretty.bytes(416).to_s.should eq("416 B")
    Pretty.bytes(3819).to_s.should eq("3.8 KB")
    Pretty.bytes(103503).to_s.should eq("103 KB")
    Pretty.bytes(12255736).to_s.should eq("12.3 MB")

    # backward compatibility (non int)
    Pretty.bytes(4567.89).to_s.should eq("4.5KiB")
  end

  context "(with block)" do
    Pretty.bytes(12255736, block: 1024).to_s.should eq("11.7 MiB")
  end

  context "(with prefix)" do
    it "(12, prefix: \"\")" do
      Pretty.bytes(12, prefix: "").to_s.should eq("12.0B")
    end
  end

  context "(with suffix)" do
    it "(416, suffix: \"bytes\")" do
      Pretty.bytes(416, suffix: "bytes").to_s.should eq("416 bytes")
    end

    it "(12255736, suffix: \"\")" do
      Pretty.bytes(12255736, suffix: "").to_s.should eq("12.3 M")
    end
  end
end

######################################################################
### new string based api

describe "Pretty.bytes" do
  it "parses String" do
    Pretty.bytes("100" ).to_s.should eq("100B")
    Pretty.bytes("8000").to_s(block: 1000).should eq("8.0KB")
    Pretty.bytes("8000").to_s.should eq("7.8KiB")
    Pretty.bytes("8K").to_s.should eq("8.0KiB")
    Pretty.bytes("8K").to_s(block: 1000).should eq("8.2KB")
    Pretty.bytes("8KB").to_s(block: 1000).should eq("8.0KB")

    Pretty.bytes("20000").to_s.should eq("19.5KiB")
    Pretty.bytes("20000").to_s(block: 1000).should eq("20.0KB")

    Pretty.bytes("20629266K").to_s.should eq("19.7GiB")
    Pretty.bytes("20629266K").to_s(block: 1000).should eq("21.1GB")
    Pretty.bytes("206292664K").to_s.should eq("196GiB")
    Pretty.bytes("206292664K").to_s(block: 1000).should eq("211GB")

    Pretty.bytes("12.3G").bytes.should eq(13207024435)
    Pretty.bytes("12.3G").kb   .should be_close(13207024.4, 0.1)
    Pretty.bytes("12.3G").kib  .should be_close(12897484.7, 0.1)
    Pretty.bytes("12.3G").mb   .should be_close(13207.0   , 0.1)
    Pretty.bytes("12.3G").mib  .should be_close(12595.1   , 0.1)
    Pretty.bytes("12.3G").gb   .should be_close(13.2      , 0.1)
    Pretty.bytes("12.3G").gib  .should be_close(12.3      , 0.1)
    Pretty.bytes("12.3G").to_s .should eq("12.3GiB")
  end
end
