require "./spec_helper"

describe Pretty::Crontab do
  describe "#time_and_date" do
    it "15 5-21/2 * * * ls" do
      Pretty::Crontab.parse("15,30 5-21/2 * * * ls").time_and_date.should eq("15,30 5-21/2 * * *")
    end
  end

  describe "#to_s" do
    it "15 5-21/2 * * * ls" do
      Pretty::Crontab.parse("15,30 5-21/2 * * * ls").to_s.should eq("15,30 5-21/2 * * * ls")
    end
  end

  describe "#inspect" do
    it "15,45 5-21/2 * * * ls /" do
      Pretty::Crontab.parse("15,45 5-21/2 * * * ls /").inspect.chomp.should eq <<-EOF
        15,45 5-21/2 * * * ls /
          mins         : [15, 45]
          hours        : [5, 7, 9, 11, 13, 15, 17, 19, 21]
          days         : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
          months       : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
          days_of_week : [0, 1, 2, 3, 4, 5, 6]
          command      : "ls /"
        EOF
    end
  end

  describe ".parse" do
    it "(empty string)" do
      expect_raises Pretty::Crontab::ParseError, %(can't parse "") do
        Pretty::Crontab.parse("")
      end
    end

    it "(invalid format)" do
      expect_raises Pretty::Crontab::ParseError, %(can't parse "This is a invalid format") do
        Pretty::Crontab.parse("This is a invalid format")
      end
    end

    it "(with special strings)" do
      cron = Pretty::Crontab.parse("@reboot ls")
      base = Pretty.local_time("2000-01-02 03:04")
      cron.command.should eq "ls"
      cron.special?.should eq "reboot"

      expect_raises Pretty::Crontab::Error, "can't calculate time for special string [@reboot]" do
        cron.next_time
      end
    end

    it "* * * * *" do
      cron = Pretty::Crontab.parse("* * * * *")
      base = Pretty.local_time("2000-01-02 03:04")
      cron.next_time(base).to_s("%H:%M").should eq("03:04")
      cron.command.should eq ""
      cron.special?.should eq nil
    end

    it "* * * * * ls" do
      cron = Pretty::Crontab.parse("* * * * * ls")
      base = Pretty.local_time("2000-01-02 03:04")
      cron.next_time(base).to_s("%H:%M").should eq("03:04")
      cron.command.should eq "ls"
      cron.special?.should eq nil
    end

    it "15 5-21/2 * * * ls /tmp /var" do
      cron = Pretty::Crontab.parse("15 5-21/2 * * * ls /tmp /var")
      base = Pretty.local_time("2019-04-18 07:48")
      cron.next_time(base).to_s("%H:%M").should eq("09:15")
      cron.command.should eq "ls /tmp /var"
      cron.special?.should eq nil
    end

    it "*/20 * * * * ls" do
      cron = Pretty::Crontab.parse("*/20 * * * * ls")
      base = Pretty.local_time("2019-04-18 07:48")
      cron.next_time(base).to_s("%H:%M").should eq("08:00")
    end

    it "3-58/5 7-21 * * * ls" do
      cron = Pretty::Crontab.parse("3-58/5 7-21 * * * ls")
      base = Pretty.local_time("2019-08-09 12:05")
      cron.next_time(base).to_s("%H:%M").should eq("12:08")
    end

    it "0,30 10-12 * * 1-5 ls [this week]" do
      cron = Pretty::Crontab.parse("0,30 10-12 * * 1-5 ls")
      base = Pretty.local_time("2019-08-09 12:15")
      cron.next_time(base).to_s("%F %H:%M").should eq("2019-08-09 12:30")
    end

    it "0,30 10-12 * * 1-5 ls [next week]" do
      cron = Pretty::Crontab.parse("0,30 10-12 * * 1-5 ls")
      base = Pretty.local_time("2019-08-09 13:15")
      cron.next_time(base).to_s("%F %H:%M").should eq("2019-08-12 10:00")
    end

    it "Uses minute accuracy" do
      cron = Pretty::Crontab.parse("* * * * *")
      base = Pretty.local_time("2000-01-02 03:04")
      cron.next_time(base).to_s("%H:%M").should eq("03:04")

      base = Pretty.local_time("2000-01-02 03:04:05")
      cron.next_time(base).to_s("%H:%M").should eq("03:04")
    end
  end
end
