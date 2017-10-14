require "./spec_helper"

private macro bytes(value, expected)
  it "({{value.id}}) # => '{{expected.id}}'" do
    Pretty.bytes({{value.id}}).should eq({{expected}})
  end
end

describe "Pretty.bytes" do
  bytes 416, "416.0 B"
  bytes 3819, "3.8 KB"
  bytes 103503, "103.5 KB"
  bytes 12255736, "12.3 MB"

  context "(with block)" do
    bytes "12255736, block: 1024", "11.7 MiB"
  end

  context "(with suffix)" do
    it "(416, suffix: \"bytes\")" do
      Pretty.bytes(416, suffix: "bytes").should eq("416.0 bytes")
    end

    it "(12255736, suffix: \"\")" do
      Pretty.bytes(12255736, suffix: "").should eq("12.3 M")
    end
  end
end
