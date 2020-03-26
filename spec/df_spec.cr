require "./spec_helper"

describe "Pretty::Df" do
  describe "Pretty.df" do
    it "runs df command" do
      (0..100).should contain(Pretty.df("/").pcent)
    end

    it "raises IO::Error when failed to execute df(1)" do
      expect_raises(IO::Error) do
        Pretty.df("")
      end
    end
  end

  describe ".parse" do
    it "(alpine)" do
      df = Pretty::Df.parse <<-EOF
        Filesystem           1K-blocks      Used Available Use% Mounted on
        overlay              206292664  95883216  99907356  49% /data
        EOF
      df.fs        .should eq("overlay")
      df.size.kib  .should eq(206292664)
      df.used.kib  .should eq(95883216)
      df.avail.kib .should eq(99907356)
      df.pcent     .should eq(49)
      df.mount     .should eq("/data")
    end

    it "(CentOS)" do
      df = Pretty::Df.parse <<-EOF
        Filesystem     1K-blocks     Used Available Use% Mounted on
        /dev/vda1       31445996 19735892  11710104  63% /
        EOF
      df.fs        .should eq("/dev/vda1")
      df.size.kib  .should eq(31445996)
      df.used.kib  .should eq(19735892)
      df.avail.kib .should eq(11710104)
      df.pcent     .should eq(63)
      df.mount     .should eq("/")
    end

    it "(no headers)" do
      expect_raises(ArgumentError, /df: no headers/) do
        Pretty::Df.parse "/dev/vda1       31445996 19735892  11710104  63% /"
      end
    end

    it "(no entries)" do
      expect_raises(ArgumentError, /df: no/) do
        Pretty::Df.parse ""
      end

      expect_raises(ArgumentError, /df: no entries/) do
        Pretty::Df.parse "Filesystem     1K-blocks     Used Available Use% Mounted on"
      end
    end
  end
end
