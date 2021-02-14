require "../spec_helper"

private def messages_in(io : IO::Memory) : Array(String)
  io.to_s.chomp.split(/\n/).map(&.split(/\s+/,2).last)
end

describe Pretty::Logger do
  it "accepts no args" do
    Pretty::Logger.new
  end

  it "works with multiple loggers" do
    debug = IO::Memory.new
    info  = IO::Memory.new
    loggers = [
      ::Logger.new(debug).tap(&.level = ::Logger::DEBUG),
      ::Logger.new(info).tap(&.level = ::Logger::INFO),
    ]
    logger = Pretty::Logger.new(loggers)
    logger.debug("debug")
    logger.info("info")

    messages_in(debug).should eq(["debug", "info"])
    messages_in(info).should eq(["info"])
  end

  it "accepts a logger too" do
    Pretty::Logger.new(::Logger.new(nil))
    Pretty::Logger.new(::Logger.new(nil), memory: ::Logger::ERROR)
  end
  
  it "accepts a composite logger too" do
    composite = Pretty::Logger.new(::Logger.new(nil))
    Pretty::Logger.new(composite)
    Pretty::Logger.new(composite, memory: ::Logger::ERROR)
  end
  
  describe "#memory, #memory?" do
    it "provides as a handy in-memory logging" do
      loggers = [::Logger.new(nil)]
      logger = Pretty::Logger.new(loggers, memory: ::Logger::ERROR)

      logger.info("info")
      logger.memory.to_s.empty?.should be_true
      logger.memory?.to_s.empty?.should be_true

      logger.error("error")
      logger.memory?.to_s.empty?.should be_false
    end

    it "raises when no memory options are given" do
      loggers = [::Logger.new(nil)]
      logger = Pretty::Logger.new(loggers)

      expect_raises(Exception, /Memory logger is not enabled/) do
        logger.memory
      end

      logger.memory?.should eq(nil)
    end

    it "works with level_op" do
      logger = Pretty::Logger.new(memory: ">=WARN")

      logger.info("info")
      logger.memory.to_s.empty?.should be_true

      logger.warn("warn")
      logger.error("error")
      messages_in(logger.memory?.not_nil!).should eq(["warn", "error"])
    end
  end

  describe "#<<" do
    it "appends logger" do
      logger = Pretty::Logger.new
      logger.size.should eq(0)
      logger << ::Logger.new(nil)
      logger.size.should eq(1)
    end
  end
  
  it "accepts Hash" do
    logger = Pretty::Logger.new
    logger << {"level" => "DEBUG"}
    logger.size.should eq(1)
    logger.first.level.debug?.should be_true
  end

  it "accepts colorize" do
    logger = Pretty::Logger.new
    logger << {"level" => "DEBUG", "colorize" => true}
    logger.size.should eq(1)
    logger.first.colorize.should be_true
  end
end
