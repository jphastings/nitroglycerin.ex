defmodule Nitroglycerin do
  @moduledoc """
  A module for encrypting and decrypting the contents of an IO device, eg. a file, using a one-time pad.
  """

  use Bitwise, skip_operators: true

  @doc """
  Encrypts `source_io` with the given `pad` (a `Nitroglycerin.Pad`) and outputs the encrypted bytes to the `target_io`.

  both `source_io` and `target_io` should be `IO.Stream`s that can be read and written with `IO.binread` and `IO.binwrite`.

  Returns the number of bytes left of the pad.

  ## Examples

      > input = File.open!("input.txt")
      > pad = Nitroglycerin.Pad.from_path("random.pad")
      > output = File.open!("output.txt.nitro", [:write])
      > Nitroglycerin.encrypt!(input, pad, output)
      15643

  """
  def encrypt!(source_io, pad, target_io) do

    state = %Nitroglycerin.State{
      target_io: target_io,
      bytes_used: 0,
      digest: :crypto.hash_init(:md5)
    }

    state
    |> add_magic_bytes
    |> add_index(pad)
    |> add_space_for_checksum(pad)
    |> add_data(source_io, pad)
    |> rewind_for_checksum(pad)
    |> add_checksum(pad)
    |> finalize(pad)
  end

  defp add_magic_bytes(state) do
    IO.binwrite(state.target_io, "NG")

    state
  end

  defp add_index(state, pad) do
    IO.binwrite(state.target_io, obfuscate_index(pad.next_index, pad.size))

    state
  end

  defp add_space_for_checksum(state, pad) do
    IO.binwrite(state.target_io, String.duplicate("\x00", 16))
    :file.position(pad.io, {:cur, 16})

    state
  end

  defp add_data(state, source_io, pad) do
    {digest, bytes_used} = IO.binstream(source_io, 1)
    |> Stream.each(&IO.binwrite(state.target_io, encrypt_byte(&1, pad)))
    |> Enum.reduce({state.digest, 0}, fn (byte, {digest, bytes_used}) ->
      {:crypto.hash_update(digest, byte), bytes_used + 1}
    end)

    %{ state | digest: digest, bytes_used: bytes_used }
  end

  defp rewind_for_checksum(state, pad) do
    :file.position(state.target_io, 10)
    :file.position(pad.io, pad.next_index)

    state
  end

  defp add_checksum(state, pad) do
    String.codepoints(:crypto.hash_final(state.digest))
    |> Stream.each(&IO.binwrite(state.target_io, encrypt_byte(&1, pad)))
    |> Stream.run

    %{ state | bytes_used: state.bytes_used + 16 }
  end

  defp finalize(state, pad), do: Nitroglycerin.Pad.used!(pad, state.bytes_used)

  defp obfuscate_index(index, pad_size) do
    # We have 8 bytes to store the index in 256 ^ 8
    blocks = div(18446744073709551616, pad_size)
    obscured_index = :rand.uniform(blocks) * pad_size + index
    <<obscured_index :: unsigned-little-64>>
  end

  defp encrypt_byte(<<byte, as::binary>>, pad) do
    <<pad_byte, as::binary>> = IO.binread(pad.io, 1)
    <<bxor(byte, pad_byte)>>
  end
end
