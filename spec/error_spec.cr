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

  describe ".where?" do
    it "skips /.crenv/ and shards" do
      backtrace = <<-EOF
        Index out of bounds (IndexError)
        0x60aaeb: first at /home/maiha/.crenv/versions/0.22.0/src/indexable.cr 251:13
        0x5824a2: query at /app/foo.cr/lib/mysql/src/connection.cr 10:8
        0x5824a2: mysql at /app/foo.cr/src/commands/db.cr 20:3
        0x5823b8: task_count at /app/foo.cr/src/commands/db.cr 13:11
        EOF
      Pretty::Error.where?(backtrace, work_dir: "/app/foo.cr").should eq("mysql at src/commands/db.cr 20:3")
    end
  end
end
