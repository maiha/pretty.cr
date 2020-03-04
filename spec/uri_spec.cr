require "./spec_helper"

describe Pretty::URI do
  it "provides escape" do
    Pretty::URI.escape("hello%x").should eq("hello%25x")
  end

  it "provides unescape" do
    Pretty::URI.unescape("hello%25x").should eq("hello%x")
  end
end
