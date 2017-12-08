require "./spec_helper"

describe "Pretty.truncate" do
  it "(string)" do
    Pretty.truncate("Hello World").should eq("Hello World")
  end

  it "(string, size: 3)" do
    Pretty.truncate("Hello World", size: 3).should eq("Hel...")
  end
end
