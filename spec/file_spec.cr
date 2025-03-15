require "./spec_helper"

private macro file_error
{% if ::Crystal::VERSION =~ /^0\.(1\d|2\d|3[0-3])\./ %}
  Errno
{% else %}
  File::Error
{% end %}
end

private def exists_dir_and_file(path : String)
  dir = File.dirname(path)
  {Dir.exists?(dir), File.exists?(path)}
end

private def home
  home = ENV["HOME"]
  return home if home == "/"
  home.chomp('/')
end

describe Pretty::File do
  describe ".mtime" do
    it "returns ::Time" do
      Pretty::File.mtime("/").should be_a(::Time)
    end
  end

  describe ".rm_f" do
    it "acts as rm(1)" do
      path = "tmp/file/foo"
      Pretty::File.write(path, "foo")
      File.exists?(path).should be_true

      # deletes if exists
      Pretty.rm_f(path)
      File.exists?(path).should be_false

      # ignore nonexistent files
      Pretty.rm_f(path)
      File.exists?(path).should be_false

      # raise when dir
      expect_raises(file_error) do
        Pretty.rm_f("tmp/file")
      end
    end
  end

  describe ".write" do
    path = "tmp/file/a/b/c/foo.txt"

    it "creates dir first if not found" do
      Pretty.rm_rf("tmp/file")
      exists_dir_and_file(path).should eq({false, false})

      Pretty::File.write(path, "foo")
      exists_dir_and_file(path).should eq({true, true})
      ::File.read(path).should eq("foo")
    end

    it "works as same as `File.write` when the dir already exists" do
      Pretty.rm_f(path)
      exists_dir_and_file(path).should eq({true, false})

      Pretty::File.write(path, "foo")
      exists_dir_and_file(path).should eq({true, true})
      ::File.read(path).should eq("foo")
    end
  end

  describe ".expand_path" do
    it "expands '~'" do
      Pretty::File.expand_path("~/foo").should eq(File.join(home, "foo"))
      Pretty.expand_path("~/foo").should eq(File.join(home, "foo"))
    end
  end
end
