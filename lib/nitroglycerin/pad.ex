defmodule Nitroglycerin.Pad do
  @enforce_keys [:path, :useage_path, :size, :io]
  defstruct [:path, :useage_path, :size, :next_index, :io]

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

  def used!(pad, bytes_used) do
    total_used = pad.next_index + bytes_used

    File.write!(
      pad.useage_path,
      Integer.to_charlist(total_used)
    )

    pad.size - total_used
  end
end