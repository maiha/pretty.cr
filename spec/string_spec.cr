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

private macro underscore(value, expected)
  it "({{value.id}}) # => '{{expected.id}}'" do
    Pretty.underscore({{value}}).should eq({{expected}})
  end
end

describe "Pretty.camelize" do
  camelize "foo", "foo"
  camelize "Foo", "foo"

  camelize "http_request", "httpRequest"
  camelize "httpRequest", "httpRequest"
  camelize "HttpRequest", "httpRequest"
end

describe "Pretty.classify" do
  classify "foo", "Foo"
  classify "Foo", "Foo"

  classify "http_request", "HttpRequest"
  classify "httpRequest", "HttpRequest"
  classify "HttpRequest", "HttpRequest"
end

describe "Pretty.underscore" do
  underscore "foo", "foo"
  underscore "Foo", "foo"

  underscore "http_request", "http_request"
  underscore "httpRequest", "http_request"
  underscore "HttpRequest", "http_request"

  underscore "group12id", "group12id"
  underscore "group12Id", "group12_id"
  underscore "Group12Id", "group12_id"
end

describe "Pretty.string_width" do
  it "works with ascii string" do
    Pretty.string_width("abc").should eq 3
  end

  it "works with multibytes string" do
    Pretty.string_width("あいう").should eq 6
  end

  it "works with ascii and multibytes string" do
    Pretty.string_width("あabいcう").should eq 9
  end
end
