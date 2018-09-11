require "./spec_helper"

private klass A
private klass SubA < A
private klass NotFound < Exception, name : String

describe "klass macro" do
  it "declares class" do
    A.is_a?(Class).should be_true
  end

  it "accepts inheritance" do
    SubA.is_a?(Class).should be_true
    (SubA < A).should be_true
  end

  it "declares an initialize method and accessor methods" do
    NotFound.is_a?(Class).should be_true
    NotFound.new(name: "foo").name.should eq("foo")
  end
end
