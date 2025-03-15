require "./spec_helper"

describe Pretty::Method do
  describe ".call" do
    it "invokes instance method by string" do
      Pretty::Method(Float64).call(1.5, "ceil").should eq 2
    end

    it "raises NotFound when the given method doesn't exist" do
      expect_raises(Pretty::Method::NotFound) do
        Pretty::Method(String).new("foo").call("xxx")
      end
    end
  end

  describe ".call?" do
    it "invokes instance method by string" do
      Pretty::Method(Float64).call?(1.5, "ceil").should eq 2
    end

    it "return nil when the given method doesn't exist" do
      Pretty::Method(String).new("foo").call?("xxx").should eq nil
    end
  end

  describe "#call" do
    it "invokes instance method by string" do
      method = Pretty::Method(Array(Int32)).new([1, 2, 3])
      method.call("size").should eq 3
    end

    it "raises NotFound when the given method doesn't exist" do
      method = Pretty::Method(String).new("foo")
      expect_raises(Pretty::Method::NotFound) do
        method.call("xxx")
      end
    end
  end

  describe "#call?" do
    it "invokes instance method by string" do
      method = Pretty::Method(Array(Int32)).new([1, 2, 3])
      method.call?("size").should eq 3
    end

    it "return nil when the given method doesn't exist" do
      method = Pretty::Method(String).new("foo")
      method.call?("xxx").should eq nil
    end
  end

  describe ".method" do
    it "builds an instance of Pretty::Method" do
      Pretty.method(1).class.should eq Pretty::Method(Int32)
    end

    it "works as well as instance" do
      Pretty.method([1, 2]).call("pop").should eq 2
    end
  end
end
