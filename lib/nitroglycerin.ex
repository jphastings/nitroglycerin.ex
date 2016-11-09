defmodule Nitroglycerin do
  @moduledoc """
  A module for encrypting and decrypting the contents of an IO device, eg. a file, using a one-time pad.
  """

  import Nitroglycerin.EncryptionMethods
  import Nitroglycerin.DecryptionMethods

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
      io: target_io,
      index: pad.next_index,
      digest: :crypto.hash_init(:md5)
    }

    state
    |> add_magic_bytes
    |> add_index(pad)
    |> add_space_for_digest(pad)
    |> add_data(source_io, pad)
    |> rewind_for_digest(pad)
    |> add_digest(pad)
    |> finalize(pad)
  end

  @doc """
  Decrypts `source_io` with the given `pad` (a `Nitroglycerin.Pad`) and outputs the decrypted bytes to the `target_io`.

  both `source_io` and `target_io` should be `IO.Stream`s that can be read and written with `IO.binread` and `IO.binwrite`.

  Returns the number of bytes left of the pad.

  ## Examples

      > input = File.open!("input.txt.nitro")
      > pad = Nitroglycerin.Pad.from_path("random.pad")
      > output = File.open!("output.txt", [:write])
      > Nitroglycerin.decrypt!(input, pad, output)
      15643

  """
  def decrypt!(source_io, pad, target_io) do

    state = %Nitroglycerin.State{
      io: source_io,
      digest: :crypto.hash_init(:md5)
    }

    state
    |> ensure_magic_bytes
    |> retrieve_index(pad)
    |> retrieve_digest(pad)
    |> retrieve_data(target_io, pad)
    |> ensure_correct_digest
    |> finalize(pad)
  end

  defp finalize(state, pad), do: Nitroglycerin.Pad.used!(pad, state.index)
end
