require "./spec_helper"

describe Pretty::Stopwatch do
  it "returns self (start, stop, reset)" do
    watch = Pretty::Stopwatch.new
    watch.start.should eq(watch)
    watch.stop .should eq(watch)
    watch.reset.should eq(watch)
  end

  it "provides count, sec and last" do
    watch = Pretty::Stopwatch.new
    watch.count.should eq(0)
    watch.sec.should eq(0.0)
    watch.last.count.should eq(0)
    watch.last.sec.should eq(0.0)
  end

  it "provides start, stop and reset" do
    watch = Pretty::Stopwatch.new

    3.times {
      watch.start
      sleep 0.01
      watch.stop
    }
    watch.count.should eq(3)
    (watch.sec > 0).should be_true
    watch.last.count.should eq(1)
    (watch.last.sec > 0).should be_true

    watch.reset
    watch.count.should eq(0)
    watch.sec.should eq(0.0)
    watch.last.count.should eq(0)
    watch.last.sec.should eq(0.0)
  end

  it "provides measure(&block) for the Loan pattern" do
    watch = Pretty::Stopwatch.new
    v = watch.measure{ "foo" }
    v.should eq("foo")
    watch.count.should eq(1)
    watch.last.count.should eq(1)
  end

  it "provides to_s by delegating to total" do
    watch = Pretty::Stopwatch.new
    watch.to_s.should eq(watch.total.to_s)

    watch.measure { "foo" }
    watch.to_s.should eq(watch.total.to_s)
  end
end
