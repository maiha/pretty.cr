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
end
