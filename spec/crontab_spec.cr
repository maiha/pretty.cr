require "./spec_helper"

describe Pretty::Crontab do
  describe "#to_s" do
    it "15 5-21/2 * * * ls" do
      Pretty::Crontab.parse("15 5-21/2 * * * ls").to_s.should eq("15 5-21/2 * * * ls")
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
      cron.cmd.should eq "ls"
      cron.special?.should eq "reboot"

      expect_raises Pretty::Crontab::Error, "can't calculate time for special string [@reboot]" do
        cron.next_time
      end
    end
    
    it "* * * * *" do
      cron = Pretty::Crontab.parse("* * * * *")
      base = Pretty.local_time("2000-01-02 03:04")
      cron.next_time(base).to_s("%H:%M").should eq("03:04")
      cron.cmd.should eq ""
      cron.special?.should eq nil
    end

    it "* * * * * ls" do
      cron = Pretty::Crontab.parse("* * * * * ls")
      base = Pretty.local_time("2000-01-02 03:04")
      cron.next_time(base).to_s("%H:%M").should eq("03:04")
      cron.cmd.should eq "ls"
      cron.special?.should eq nil
    end

    it "15 5-21/2 * * * ls /tmp /var" do
      cron = Pretty::Crontab.parse("15 5-21/2 * * * ls /tmp /var")
      base = Pretty.local_time("2019-04-18 07:48")
      cron.next_time(base).to_s("%H:%M").should eq("09:15")
      cron.cmd.should eq "ls /tmp /var"
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
  end
end
