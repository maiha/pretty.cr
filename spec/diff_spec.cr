require "./spec_helper"

private macro diff(a,b)
  Pretty.diff({{a}}, {{b}})
end

describe "Pretty.diff" do
  it "returns a Pretty::Diff" do
    diff(1,2).should be_a(Pretty::Diff)
  end

  context "(equal objects)" do
    it "#size returns 0" do
      diff(nil,nil).size.should eq(0)
      diff(1,1).size.should eq(0)
      diff(["a"],["a"]).size.should eq(0)
    end
  end

  context "(type mismatch)" do
    it "#size returns 1" do
      diff(1,nil).size.should eq(1)
      diff(1, "a").size.should eq(1)
      diff(1, ["a"]).size.should eq(1)
    end

    it "#to_s shows type info" do
      diff(1,nil).to_s.should eq("Expected 'Int32', but got 'Nil'")
    end
  end

  context "(value mismatch)" do
    it "#size returns 1" do
      diff(true,false).size.should eq(1)
      diff(1,2).size.should eq(1)
      diff("a", "b").size.should eq(1)
    end

    it "#to_s shows value info" do
      diff(1,2).to_s.should eq("Expected '1', but got '2'")
    end
  end

  context "(value mismatch with enumerable)" do
    describe "#size" do
      it "returns the number of different elements" do
        diff([1], [1,2]).size.should eq(1)
        diff([1], [0,2]).size.should eq(2)
        diff([] of Int32, (1..5).to_a).size.should eq(5)
      end
    end
  end

  context "(value mismatch with nested enumerable)" do
    describe "#size" do
      it "returns the number of different elements" do
        csv1 = parse_cvs <<-EOF
          112433,2017-11-13 00:00:00 UTC,2017-11-13 00:00:00,00:00:00,15,0
          112465,2017-11-13 00:00:00 UTC,2017-11-13 00:00:00,00:00:00,7293,273
          EOF
        csv2 = parse_cvs <<-EOF
          112433,2017-11-13 00:00:00,2017-11-13,00:00:00,15,0
          112465,2017-11-13 00:00:00,2017-11-13,00:00:00,7293,273
          EOF

        diff(csv1, csv2).size.should eq(2)
      end
    end
  end
end

private def parse_cvs(buf)
  buf.split(/\n/).map(&.split(","))
end
