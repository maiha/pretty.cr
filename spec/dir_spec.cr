require "./spec_helper"

private def tmp_dir : String
  File.join(ROOT_DIR, "tmp/spec/dir/a/b")
end

describe "Pretty::Dir" do
  describe ".clean(path)" do
    it "mkpath" do
      ::Pretty.rm_rf(tmp_dir)
      Dir.exists?(tmp_dir).should be_false

      Pretty::Dir.clean(tmp_dir)
      Dir.exists?(tmp_dir).should be_true
    end
  end
end
