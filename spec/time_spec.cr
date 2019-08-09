require "./spec_helper"

private macro utc(*args)
  {% if ::Crystal::VERSION =~ /^0\.(1\d|2[0-7])\./ %}
    ::Time.new({{*args}}, location: Time::Location::UTC)
  {% else %}
    ::Time.utc({{*args}})
  {% end %}
end

private macro parse(value, time)
  it {{value}} do
    begin
      exp = {{time}}
      got = Pretty.time({{value}}, location: Time::Location::UTC)
      if got == exp
        got.should eq(exp)
      else
        # In error case, print time string rather than epoch itself
        Pretty.time({{value}}, location: Time::Location::UTC).to_s("%FT%T.%L %z").should eq(({{time}}).to_s("%FT%T.%L %z"))
      end
    rescue err : Pretty::Time::ParseError
      fail err.to_s
    end
  end
end

describe "Pretty.time" do
  # Date
  it "parse 2000-01-02" do
    t = Pretty::Time.parse("2000-01-02", ::Time::Location.local)
    t.year.should eq(2000)
    t.month.should eq(1)
    t.day.should eq(2)
    t.local?.should be_true
    t.should eq t.at_beginning_of_day
  end

  # Time
  parse "2000-01-02 03:04:05"     , utc(2000,1,2,3,4,5)
  parse "2000-01-02 03:04:05Z"    , utc(2000,1,2,3,4,5)
  parse "2000-01-02 03:04:05.678" , utc(2000,1,2,3,4,5) + 678.milliseconds
  parse "2000-01-02 03:04:05.678Z", utc(2000,1,2,3,4,5) + 678.milliseconds
  parse "2000-01-02 03:04:05.000 UTC", utc(2000,1,2,3,4,5)
  parse "2000-01-02 03:04:05 UTC"    , utc(2000,1,2,3,4,5)
  
  # Timezone
  parse "2000-01-02T03:04:05Z"          , utc(2000,1,2,3,4,5)
  parse "2000-01-02T03:04:05+0900"      , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02T03:04:05 +0900"     , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02 03:04:05 +0900"     , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02T03:04:05.678+09:00" , utc(2000,1,2,3,4,5) + 678.milliseconds - 9.hours
  parse "2000-01-02T03:04:05.678 +09:00", utc(2000,1,2,3,4,5) + 678.milliseconds - 9.hours
  parse "2000-01-02 03:04:05 +0900 Japan", utc(2000,1,2,3,4,5) - 9.hours  
  parse "2000-01-02 03:04:05 -03:00 America/Buenos_Aires", (utc(2000,1,2,3,4,5) + 3.hours)
  parse "2000-01-02 03:04:05.0 +09:00 Asia/Tokyo", utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02 03:04:05.0 +02:00 Europe/Berlin", utc(2000,1,2,3,4,5) - 2.hours
  
  # Best effort
  parse "2000-01-02 03:04"        , utc(2000,1,2,3,4,0)
  parse "2000-01-02-03:04"        , utc(2000,1,2,3,4,0)
  parse "2000-01-02-03-04"        , utc(2000,1,2,3,4,0)
  parse "2000-01-02-03:04:05"     , utc(2000,1,2,3,4,5)
  parse "2000-01-02-03-04-05"     , utc(2000,1,2,3,4,5)
  # (some people like this forms)
  parse "2000/01/02 03:04"        , utc(2000,1,2,3,4,0)
  parse "2000/01/02 03:04:05"     , utc(2000,1,2,3,4,5)
  # (like filenames)
  parse "20000102-0304"           , utc(2000,1,2,3,4,0)
  parse "20000102-030405"         , utc(2000,1,2,3,4,5)

  context "(invalid input)" do
    it "raises " do
      expect_raises(Pretty::Time::ParseError) do
        Pretty.time("foo")
      end
    end
  end
end

describe "Pretty.time?" do
  context "(valid input)" do
    it "acts as same as '.time'" do
      s = "2000-01-02 03:04:05"
      Pretty.time?(s).should eq(Pretty.time(s))
    end
  end

  context "(invalid input)" do
    it "returns nil" do
      Pretty.time?("foo").should eq(nil)
    end
  end
end

describe Pretty do
  describe ".now" do
    it "works" do
      Pretty.now.should be_a(Time)
      Pretty::Time.now.should be_a(Time)
    end
  end
end

describe Pretty::Time do
  describe ".parse" do
    it "acts as same as 'Pretty.time'" do
      s = "2000-01-02 03:04:05"
      Pretty::Time.parse(s).should eq(Pretty.time(s))

      expect_raises(Pretty::Time::ParseError) do
        Pretty::Time.parse("foo")
      end
    end
  end

  describe ".parse?" do
    it "acts as same as 'Pretty.time?'" do
      s = "2000-01-02 03:04:05"
      Pretty::Time.parse?(s).should eq(Pretty.time?(s))
      Pretty::Time.parse?("foo").should eq(nil)
    end
  end
end

describe "Pretty.epoch" do
  it "delegates to Time" do
    time = Pretty.epoch(981173106)
    time.year        .should eq(2001)
    time.month       .should eq(2)
    time.day         .should eq(3)
    time.hour        .should eq(4)
    time.minute      .should eq(5)
    time.second      .should eq(6)
    time.millisecond .should eq(0)
  end
end

describe "Pretty.epoch_ms" do
  it "delegates to Time" do
    time = Pretty.epoch_ms(981173106789)
    time.year        .should eq(2001)
    time.month       .should eq(2)
    time.day         .should eq(3)
    time.hour        .should eq(4)
    time.minute      .should eq(5)
    time.second      .should eq(6)
    time.millisecond .should eq(789)
  end
end
