defmodule Nitroglycerin.Pad do
  @moduledoc """
  A struct & constructor for holding the key details about a one-time pad file.
  """

  @enforce_keys [:path, :useage_path, :size, :io]
  defstruct [:path, :useage_path, :size, :next_index, :io]

  @doc """
  Generate a completed `Nitroglycerin.Pad` from the pathname of a pad file.

  If the pad file doesn't exist, this struct will form the basis of the one that will be written.

  ## Examples

      > Nitroglycerin.Pad.from_path("random.pad")
      %Nitroglycerin.Pad{
        path: "random.pad",
        useage_path: "random.pad.useage",
        size: 12345678,
        io: #PID<0.0.0>,
        next_index: 0,
      }
  """
  def from_path(pad_path) do
    %{size: size} = File.stat!(pad_path)

    pad = %Nitroglycerin.Pad{
      path: pad_path,
      useage_path: "#{pad_path}.useage",
      size: size,
      io: File.open!(pad_path),
    }

    next_index = case File.read(pad.useage_path) do
      {:ok, bytes} -> elem(Integer.parse(bytes), 0)
      {:error, _}  -> 0
    end

    :file.position(pad.io, next_index)

    %{ pad | next_index: next_index }
  end

  @doc """
  Record that some of a pad has been used.

  Assumes that you have used `bytes_used` bytes from the `next_index` of the given `pad`.

  ## Examples

  Record that 1024 bytes have been used:

      > Nitroglycerin.Pad.used!(pad, 1024)

  Ensure a pad has been written to disk:

      > Nitroglycerin.Pad.used!(pad, 0)
  """
  def used!(pad, bytes_used) do
    total_used = pad.next_index + bytes_used

    File.write!(
      pad.useage_path,
      Integer.to_charlist(total_used)
    )

    pad.size - total_used
  end
end