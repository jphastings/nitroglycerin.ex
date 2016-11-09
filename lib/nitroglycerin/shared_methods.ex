defmodule Nitroglycerin.SharedMethods do
  @moduledoc false
  use Bitwise, skip_operators: true

  def obfuscate_index(index, pad) do
    # We have 8 bytes to store the index in 256 ^ 8
    blocks = div(18446744073709551616, pad.size)
    obscured_index = :rand.uniform(blocks) * pad.size + index
    <<obscured_index :: unsigned-little-64>>
  end

  def deobfuscate_index(obfuscated_index, pad) do
    rem(obfuscated_index, pad.size)
  end

  def crypt_byte(<<byte, _::binary>>, pad) do
    <<pad_byte, _::binary>> = IO.binread(pad.io, 1)
    <<bxor(byte, pad_byte)>>
  end

  def update_hash_and_increment(byte, {digest, bytes_used}) do
    {
      :crypto.hash_update(digest, byte),
      bytes_used + 1
    }
  end
end
