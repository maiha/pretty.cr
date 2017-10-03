require "./spec_helper"

private def array
  [
    ["user", "maiha"],
    ["password", "123"],
  ]
end

describe "Pretty.lines" do
  it "(array)" do
    Pretty.lines(array).should eq <<-EOF
      user    maiha
      password123
      EOF
  end

  it "(array, delimiter: \" = \")" do
    Pretty.lines(array, delimiter: " = ").should eq <<-EOF
      user     = maiha
      password = 123
      EOF
  end

  it "(array, indent: \"> \")" do
    Pretty.lines(array, indent: "> ").should eq <<-EOF
      > user    maiha
      > password123
      EOF
  end
end
