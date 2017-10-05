require "./spec_helper"

private def json : String
  %({"id": "123", "name": "maiha"})
end

describe "Pretty.json" do
  it "(string)" do
    Pretty.json(json).should eq <<-EOF
      {
        "id": "123",
        "name": "maiha"
      }
      EOF
  end

  it "(string, color: true)" do
    Pretty.json(json, color: true).should eq <<-EOF
      {
        \e[36m\"id\"\e[0m: \e[33m\"123\"\e[0m,
        \e[36m\"name\"\e[0m: \e[33m\"maiha\"\e[0m
      }
      EOF
  end
end
