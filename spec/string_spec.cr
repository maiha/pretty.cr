require "./spec_helper"

private macro camelize(value, expected)
  it "({{value.id}}) # => '{{expected.id}}'" do
    Pretty.camelize({{value}}).should eq({{expected}})
  end
end

private macro classify(value, expected)
  it "({{value.id}}) # => '{{expected.id}}'" do
    Pretty.classify({{value}}).should eq({{expected}})
  end
end

describe "Pretty.camelize" do
  camelize "foo", "foo"
  camelize "Foo", "foo"

  camelize "http_request", "httpRequest"
  camelize "httpRequest" , "httpRequest"
  camelize "HttpRequest" , "httpRequest"
end

describe "Pretty.classify" do
  classify "foo", "Foo"
  classify "Foo", "Foo"

  classify "http_request", "HttpRequest"
  classify "httpRequest" , "HttpRequest"
  classify "HttpRequest" , "HttpRequest"
end
