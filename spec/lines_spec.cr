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

  it "(array) with multibytes" do
    array = [
      ["1","2"],
      ["あ","い"],
    ]
    
    Pretty.lines(array, delimiter: "|").should eq <<-EOF
      1 |2
      あ|い
      EOF
  end

  it "(array) with unbalanced items" do
    array = [
      ["1"],
      ["a","b"],
      ["Z"],
    ]
    
    Pretty.lines(array, delimiter: "|").should eq <<-EOF
      1|
      a|b
      Z|
      EOF
  end

  it "(array) with headers" do
    headers = ["1","2","3"]
    array = [
      ["a","foo", "x"],
    ]
    
    Pretty.lines(array, headers: headers).should eq <<-EOF
      12  3
      -----
      afoox
      EOF
    
    Pretty.lines(array, headers: headers, delimiter: "|").should eq <<-EOF
      1|2  |3
      -|---|-
      a|foo|x
      EOF
  end

  # TODO: ANSI colors vary by TERM. (#4)
  pending "supports ansi colors" do
    array = [
      ["foo", "bar".colorize(:cyan).to_s],
      ["hello".colorize(:green).to_s, "world"],
    ]
    
    Pretty.lines(array, delimiter: " ").should eq <<-EOF
      foo   \e[36mbar\e[0m
      \e[32mhello\e[0m world
      EOF
  end
end
