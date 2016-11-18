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

  def crypt_string(<<bytes::binary>>, pad) do
    <<pad_bytes::binary>> = IO.binread(pad.io, byte_size(bytes))
    
    zipped = Enum.zip(
      :binary.bin_to_list(bytes),
      :binary.bin_to_list(pad_bytes)
    )

    :binary.list_to_bin(Enum.map(zipped, fn({a, b}) -> bxor(a, b) end))
  end

  def update_hash_and_increment(string, {digest, bytes_used}) do
    {
      :crypto.hash_update(digest, string),
      bytes_used + byte_size(string)
    }
  end
end
