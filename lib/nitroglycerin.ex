defmodule Nitroglycerin do
  @moduledoc """
  """
  use Bitwise, skip_operators: true

  def encrypt!(source_pid, pad_path, target_path) do
    target_pid = File.open!(target_path, [:write, :binary])
    IO.binwrite(target_pid, "NG")

    {pad_pid, length, index} = pad_details(pad_path)
    IO.binwrite(target_pid, obfuscate_index(index, length))

    digest = :crypto.hash_init(:md5)
    {digest, bytes_used} = IO.binstream(source_pid, 1)
    |> Stream.each(&IO.binwrite(target_pid, char_xor(&1, IO.binread(pad_pid, 1))))
    |> Enum.reduce({digest, 0}, fn (byte, {digest, bytes_used}) ->
      {:crypto.hash_update(digest, byte), bytes_used + 1}
    end)

    String.codepoints(:crypto.hash_final(digest))
    |> Stream.each(&IO.binwrite(target_pid, char_xor(&1, IO.binread(pad_pid, 1))))
    |> Stream.run

    advance_pad!(pad_path, index, bytes_used)
    File.close(target_pid)
  end

  defp obfuscate_index(index, pad_size) do
    # We have 8 bytes to store the index in 256 ^ 8
    blocks = div(18446744073709551616, pad_size)
    obscured_index = :rand.uniform(blocks) * pad_size + index
    <<obscured_index :: unsigned-little-64>>
  end

  defp char_xor(<<a, as::binary>>, <<b, as::binary>>) do
    <<bxor(a, b)>>
  end

  defp pad_details(pad_path) do
    pad_pid = File.open!(pad_path, [:read, :binary])
    %{size: length} = File.stat!(pad_path)

    index = case File.read(pad_useage_path(pad_path)) do
      {:ok, bytes} -> elem(Integer.parse(bytes), 0)
      {:error, _}  -> 0
    end

    :file.position(pad_pid, index)
    {pad_pid, length, index}
  end

  defp advance_pad!(pad_path, from, byte_count) do
    File.write!(
      pad_useage_path(pad_path),
      Integer.to_charlist(from + byte_count)
    )
  end

  defp pad_useage_path(pad_path) do
    "#{pad_path}.useage"
  end
end
