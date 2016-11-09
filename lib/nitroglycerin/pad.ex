defmodule Nitroglycerin.Pad do
  @moduledoc """
  A struct & constructor for holding the key details about a one-time pad file.
  """

  @enforce_keys [:path, :usage_path, :size, :io]
  defstruct [:path, :usage_path, :size, :next_index, :io]

  @doc """
  Generate a completed `Nitroglycerin.Pad` from the pathname of a pad file.

  If the pad file doesn't exist, this struct will form the basis of the one that will be written.

  ## Examples

      > Nitroglycerin.Pad.from_path("random.pad")
      %Nitroglycerin.Pad{
        path: "random.pad",
        usage_path: "random.pad.usage",
        size: 12345678,
        io: #PID<0.0.0>,
        next_index: 0,
      }
  """
  def from_path(pad_path) do
    %{size: size} = File.stat!(pad_path)

    pad = %Nitroglycerin.Pad{
      path: pad_path,
      usage_path: "#{pad_path}.usage",
      size: size,
      io: File.open!(pad_path),
    }

    next_index = case File.read(pad.usage_path) do
      {:ok, bytes} -> elem(Integer.parse(bytes), 0)
      {:error, _}  -> 0
    end

    :file.position(pad.io, next_index)

    %{ pad | next_index: next_index }
  end

  @doc """
  Record that some of a pad has been used.

  Assumes that you have used `used_up_to` bytes from the start of the given `pad`. If a number
  smaller than the one already stored is given then the largest will be left in the pad usage file.

  ## Examples

  Record that the first 1024 bytes have been used:

      > Nitroglycerin.Pad.used!(pad, 1024)

  Ensure a pad has been written to disk:

      > Nitroglycerin.Pad.used!(pad, 0)
  """
  def used!(pad, used_up_to) do
    File.write!(
      pad.usage_path,
      max(
        Integer.to_charlist(used_up_to),
        pad.next_index
      )
    )

    pad.size - used_up_to
  end
end