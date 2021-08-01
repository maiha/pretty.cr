require "./spec_helper"

describe Pretty::Crystal do
  describe ".version" do
    it "returns a Version" do
      version = Pretty::Crystal.version
      version.should be_a(Pretty::Version)
      (version.major > 0 || version.minor > 0).should be_true
      version.to_s.should eq(Crystal::VERSION)
    end
  end
end
