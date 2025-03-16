# `Pretty::UsedMemory` represents kb based memory infomation.
# This data is used from `Pretty::MemInfo` and `Pretty::ProcessInfo`
#
# ### Usage
#
# ```
# Pretty::UsedMemory.new(1_234_567).bytes # => 1234567000
# Pretty::UsedMemory.new(1_234_567).kb    # => 1234567
# Pretty::UsedMemory.new(1_234_567).mb    # => 1234.567
# Pretty::UsedMemory.new(1_234_567).gb    # => 1.234567
# Pretty::UsedMemory.new(1_234_567).to_s  # => "1.2GB"
# ```

record Pretty::UsedMemory, kb : Int64 do
  def_equals kb

  def +(other)
    UsedMemory.new(kb + other.kb)
  end

  def bytes : Int64
    kb * 1_000
  end

  def mb : Float64
    kb.to_f / 1_000
  end

  def gb : Float64
    kb.to_f / 1_000_000
  end

  def to_s(io : IO)
    io << Pretty.bytes(bytes, prefix: "")
  end

  def self.zero
    new(0)
  end

  def self.from_gb(v)
    new((v * 1_000_000).ceil.to_i64)
  end
end
