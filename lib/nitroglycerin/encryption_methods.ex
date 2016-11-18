defmodule Nitroglycerin.EncryptionMethods do
  @moduledoc false
  import Nitroglycerin.SharedMethods

  def add_magic_bytes(state) do
    IO.binwrite(state.io, "NG")

    state
  end

  def add_index(state, pad) do
    IO.binwrite(state.io, obfuscate_index(pad.next_index, pad))

    state
  end

  def add_space_for_digest(state, pad) do
    IO.binwrite(state.io, String.duplicate("\x00", 16))
    :file.position(pad.io, {:cur, 16})

    state
  end

  def add_data(state, source_io, pad) do
    {digest, total_bytes_used} = IO.binstream(source_io, 1024)
    |> Stream.each(&IO.binwrite(state.io, crypt_string(&1, pad)))
    |> Enum.reduce({state.digest, 0}, &update_hash_and_increment(&1, &2))

    %{ state | digest: digest, index: state.index + total_bytes_used }
  end

  def rewind_for_digest(state, pad) do
    :file.position(state.io, 10)
    :file.position(pad.io, pad.next_index)

    state
  end

  def add_digest(state, pad) do
    IO.binwrite(state.io, crypt_string(:crypto.hash_final(state.digest), pad))

    %{ state | index: state.index + 16 }
  end
end
