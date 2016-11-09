defmodule Nitroglycerin.DecryptionMethods do
  @moduledoc false
  import Nitroglycerin.SharedMethods

  def ensure_magic_bytes(state) do
    if IO.binread(state.io, 2) != "NG" do
      raise Nitroglycerin.Errors.InvalidFile
    end

    state
  end

  def retrieve_index(state, pad) do
    << obfuscated_index :: unsigned-little-64 >> = IO.binread(state.io, 8)
    index = deobfuscate_index(obfuscated_index, pad)
    :file.position(pad.io, index)

    %{ state | index: index }
  end

  def retrieve_digest(state, pad) do
    checksum = IO.binstream(state.io, 1)
    |> Stream.take(16)
    |> Enum.reduce(<<>>, &(&2 <> crypt_byte(&1, pad)))

    %{ state | checksum: checksum, index: state.index + 16 }
  end

  def retrieve_data(state, target_io, pad) do
    {digest, bytes_used} = IO.binstream(state.io, 1)
    |> Stream.map(&crypt_byte(&1, pad))
    |> Stream.each(&IO.binwrite(target_io, &1))
    |> Enum.reduce({state.digest, 0}, &update_hash_and_increment(&1, &2))

    %{ state | digest: digest, index: state.index + bytes_used }
  end

  def ensure_correct_digest(state) do
    if :crypto.hash_final(state.digest) != state.checksum do
      raise Nitroglycerin.Errors.IncorrectPad
    end

    state
  end
end
