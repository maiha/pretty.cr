require "./spec_helper"

private def memory
  Pretty::UsedMemory.new(1_234_567)
end

describe Pretty::UsedMemory do
  it "provides kb" do
    memory.bytes.should eq(1_234_567_000)
  end

  it "provides kb" do
    memory.kb.should eq(1_234_567)
  end

  it "provides mb" do
    memory.mb.should eq(1234.567)
  end

  it "provides gb" do
    memory.gb.should eq(1.234567)
  end

  it "provides to_s" do
    memory.to_s.should eq("1.2GB")
  end

  describe ".from_gb" do
    it "instantiates with GB value" do
      Pretty::UsedMemory.from_gb(1.234567).kb.should eq(1_234_567)
    end
  end
end
