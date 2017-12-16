require "./spec_helper"

private macro utc(*args)
  Time.new({{*args}}, kind: Time::Kind::Utc)
end

private macro parse(value, time)
  it {{value}} do
    begin
      exp = {{time}}
      got = Pretty.time({{value}}, kind: Time::Kind::Utc)
      if got.epoch_ms == exp.epoch_ms
        got.should eq(exp)
      else
        # In error case, print time string rather than epoch itself
        Pretty.time({{value}}, kind: Time::Kind::Utc).to_s("%FT%T.%L %z").should eq(({{time}}).to_s("%FT%T.%L %z"))
      end
    rescue err : Pretty::Time::ParseError
      fail err.to_s
    end
  end
end

describe "Pretty.time" do
  # Date
  parse "2000-01-02", utc(2000,1,2)

  # Time
  parse "2000-01-02 03:04:05"     , utc(2000,1,2,3,4,5)
  parse "2000-01-02 03:04:05Z"    , utc(2000,1,2,3,4,5)
  parse "2000-01-02 03:04:05.678" , utc(2000,1,2,3,4,5) + 678.milliseconds
  parse "2000-01-02 03:04:05.678Z", utc(2000,1,2,3,4,5) + 678.milliseconds

  # Timezone
  parse "2000-01-02T03:04:05Z"          , utc(2000,1,2,3,4,5)
  parse "2000-01-02T03:04:05+0900"      , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02T03:04:05 +0900"     , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02 03:04:05 +0900"     , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02T03:04:05.678+09:00" , utc(2000,1,2,3,4,5) + 678.milliseconds - 9.hours
  parse "2000-01-02T03:04:05.678 +09:00", utc(2000,1,2,3,4,5) + 678.milliseconds - 9.hours

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
