require "./spec_helper"

describe Pretty::Ansi do
  describe ".remove_ansi" do
    it "removes ansi escapes" do
      Pretty.remove_ansi("foo".colorize(:green)).should eq("foo")
      Pretty.remove_ansi("\e[31;1mfoo\e[0m").should eq("foo")
    end
  end
end
