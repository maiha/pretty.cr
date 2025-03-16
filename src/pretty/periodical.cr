module Pretty::Periodical
  class Executor
    property! next_report_time : ::Time?
    @interval : ::Time::Span = 1.seconds

    def initialize(interval = 1)
      self.interval = interval
    end

    def interval=(v : Int32 | ::Time::Span) : Executor
      v = v.seconds if v.is_a?(Int32)
      @interval = v
      update_next_report_time!
      return self
    end

    def execute(&)
      if next_report_time <= Time.now
        yield
        update_next_report_time!
      end
    end

    private def update_next_report_time!
      @next_report_time = Time.now + @interval
    end
  end
end

def Pretty.periodical(*args, **opts)
  Pretty::Periodical::Executor.new(*args, **opts)
end
