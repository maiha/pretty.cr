require "./spec_helper"

class Foo
  def foo
    raise "foo"
  end
end

describe "Pretty::Error" do
  describe "#where" do
    it "works" do
      begin
        Foo.new.foo
      rescue err
        Pretty::Error.new(err).where.should match(%r{foo at spec/error_spec})
      end
    end
  end
end
