require "./spec_helper"

describe "Pretty.number" do
  it "(10) simply returns a string" do
    Pretty.number(10).should eq("10")
  end

  it "(1000000) gives commas" do
    Pretty.number(1000000).should eq("1,000,000")
  end
end
