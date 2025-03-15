require "./spec_helper"

describe Pretty::Periodical::Executor do
  it "doesn't execute unless the specified time has elapsed" do
    count = 0
    ctx = Pretty.periodical(3.seconds)
    ctx.execute { count += 1 } # skip
    ctx.execute { count += 1 } # skip
    count.should eq(0)
  end

  it "executes if the specified time has elapsed" do
    count = 0
    ctx = Pretty.periodical(0.1.seconds)
    sleep 0.1.seconds          # (wait 0.1 seconds)
    ctx.execute { count += 1 } # executed
    ctx.execute { count += 1 } # skip
    count.should eq(1)
  end

  it "executes many times if the specified time has elapsed" do
    count = 0
    ctx = Pretty.periodical(0.1.seconds)
    sleep 0.1.seconds          # (wait 0.1 seconds)
    ctx.execute { count += 1 } # executed
    sleep 0.1.seconds          # (wait 0.1 seconds)
    ctx.execute { count += 1 } # executed
    count.should eq(2)
  end

  it "works without args" do
    ctx = Pretty.periodical
    ctx.execute { }
  end
end
