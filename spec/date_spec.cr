require "./spec_helper"

describe Pretty::Date do
  describe ".parse" do
    # YMD
    parse "2001-02-03", time(2001,2,3)
    parse "2001/02/03", time(2001,2,3)
    parse "20010203"  , time(2001,2,3)

    # Like "date -d ..." in "coreutils/gnulib-tests/test-parse-datetime.c"
    parse "+1 day", (today + 1.day)
    parse_error "+40 yesterday"
    parse_error "-4 today"
    parse "1 day ago", (today - 1.day)
    parse "1 day hence", (today + 1.day)
    parse_error "40 now ago"
    parse_error "last tomorrow"
    parse_error "next yesterday"
    parse "now", today
    parse "today", today
    parse_error "tomorrow ago"
    parse_error "tomorrow hence"
    parse "tomorrow", (today + 1.day)
    parse "yesterday", (today - 1.day)
  end

  describe ".parse?" do
    it "acts same as parse for success cases" do
      Pretty::Date.parse?("2001-02-03").should eq(time(2001,2,3))
    end

    it "returns nil for failure cases" do
      Pretty::Date.parse?("foo").should eq(nil)
    end
  end

  describe ".parse_dates" do
    parse_dates "20180901", [time(2018,9,1)]
    parse_dates "20180908-20180909", [time(2018,9,8), time(2018,9,9)]

    it "20180830-20180902" do
      Pretty.dates("20180830-20180902").map(&.to_s("%Y%m%d")).should eq(["20180830", "20180831", "20180901", "20180902"])
    end

    it "201809 # (30 days)" do
      Pretty.dates("201809").size.should eq(30)
    end

    it "201801-201802 # (59 days)" do
      Pretty.dates("201801-201802").size.should eq(59)
    end

    it "201801-20180203 # (34 days)" do
      Pretty.dates("201801-20180203").size.should eq(34)
    end

    it "20180901-20180830 # (0 days)" do
      Pretty.dates("20180901-20180830").size.should eq(0)
    end

    it "3 day ago - 1 days ago # (3 days)" do
      Pretty.dates("3 day ago - 1 days ago").size.should eq(3)
    end
  end

  describe ".parse_dates?" do
    it "acts same as parse_dates for success cases" do
      Pretty::Date.parse_dates?("20010203").should eq([time(2001,2,3)])
    end

    it "returns nil for failure cases" do
      Pretty::Date.parse_dates?("foo").should eq(nil)
    end
  end
end

describe Pretty do
  describe ".date" do
    it "acts same as Pretty::Date.parse" do
      Pretty.date("2001-02-03").should eq(Pretty::Date.parse("2001-02-03"))
      expect_raises(Pretty::Date::ParseError) do
        Pretty.date("foo")
      end
    end
  end

  describe ".date?" do
    it "acts same as Pretty::Date.parse" do
      Pretty.date?("2001-02-03").should eq(Pretty::Date.parse?("2001-02-03"))
      Pretty.date?("foo").should eq(nil)
    end
  end
end

private def time(*args)
  Pretty.now(*args)
end

private def today
  Pretty.now.at_beginning_of_day
end

private def parse(value, exp)
  it value.inspect do
    begin
      got = Pretty::Date.parse(value)
      if got == exp
        got.should eq(exp)
      else
        # In error case, print time string rather than epoch itself
        Pretty::Date.parse(value).should eq(exp)
      end
    rescue err : Pretty::Date::ParseError
      fail err.to_s
    end
  end
end

private def parse_error(value)
  it "#{value.inspect} # => fail" do
    expect_raises(Pretty::Date::ParseError) do
      Pretty::Date.parse(value)
    end
  end
end

private def parse_dates(value, exp)
  it value.inspect do
    begin
      got = Pretty::Date.parse_dates(value)
      if got == exp
        got.should eq(exp)
      else
        # In error case, print time string rather than epoch itself
        Pretty::Date.parse_dates(value).should eq(exp)
      end
    rescue err : Pretty::Date::ParseError
      fail err.to_s
    end
  end
end

private def parse_dates_error(value)
  it "#{value.inspect} # => fail" do
    expect_raises(Pretty::Date::ParseError) do
      Pretty::Date.parse_dates(value)
    end
  end
end
