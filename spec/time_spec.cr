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
  parse "2000-01-02 03:04:05"    , utc(2000,1,2,3,4,5)
  parse "2000-01-02 03:04:05.678", utc(2000,1,2,3,4,5) + 678.milliseconds

  # Timezone
  parse "2000-01-02T03:04:05+0900"      , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02T03:04:05 +0900"     , utc(2000,1,2,3,4,5) - 9.hours
  parse "2000-01-02T03:04:05.678+09:00" , utc(2000,1,2,3,4,5) + 678.milliseconds - 9.hours
  parse "2000-01-02T03:04:05.678 +09:00", utc(2000,1,2,3,4,5) + 678.milliseconds - 9.hours
end
