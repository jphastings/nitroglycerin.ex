defmodule Nitroglycerin do
  @moduledoc """
  """
  use Bitwise, skip_operators: true

  def encrypt(source_pid, pad_pid, target_pid) do
    IO.binwrite(target_pid, "NG")

    # Index 
    IO.binwrite(target_pid, String.duplicate("\x00", 8))

    # Digest section, zeros for now
    IO.binwrite(target_pid, String.duplicate("\x00", 16))

    digest = :crypto.hash_init(:md5)
    digest = IO.binstream(source_pid, 1)
    |> Stream.each(&IO.binwrite(target_pid, char_xor(&1, IO.binread(pad_pid, 1))))
    |> Enum.reduce(digest, &:crypto.hash_update(&2, &1))

    :file.position(target_pid, 10)
    IO.binwrite(target_pid, :crypto.hash_final(digest))
  end

  defp char_xor(a, b) do
    # TODO: This _can't_ be the most efficient/concise way of doing this?
    combined = bxor(
      List.first(String.to_charlist(a)),
      List.first(String.to_charlist(b))
    )
    String.Chars.to_string([combined])
  end
end
