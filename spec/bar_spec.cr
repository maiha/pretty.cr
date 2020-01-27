require "./spec_helper"

describe Pretty::Bar do
  it "Pretty.bar returns Ascii-art bar" do
    Pretty.bar(83,100, width: 20).bar.should eq("||||||||||||||||    ")
  end

  it "works" do
    bar = Pretty::Bar.new(val: 36, max: 50, width: 20, mark: "=", empty: ".")

    # reflections
    bar.val  .should eq(36)
    bar.max  .should eq(50)
    bar.width.should eq(20)
    bar.mark .should eq("=")
    bar.empty.should eq(".")

    # calculated
    bar.pct  .should eq(72)
    bar.pct_s.should eq(" 72%")
    bar.val_s.should eq("36/50")
    bar.bar  .should eq("==============......")
    bar.to_s .should eq("[==============......] 36/50 ( 72%)")
  end

  it "(README)" do
    vals = [8793, 6917, 5534, 8720]
    vals.map{|v| Pretty.bar(v, max: 10000, width: 20)}.join("\n").should eq <<-EOF
[|||||||||||||||||   ]  8793/10000 ( 87%)
[|||||||||||||       ]  6917/10000 ( 69%)
[|||||||||||         ]  5534/10000 ( 55%)
[|||||||||||||||||   ]  8720/10000 ( 87%)
EOF
  end
end
