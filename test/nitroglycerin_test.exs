defmodule NitroglycerinTest do
  use ExUnit.Case
  doctest Nitroglycerin

  test "golden path encryption" do
    content = "Content"
    pad_length = String.length(content)

    source_pid = File.open!(content, [:ram, :binary])
    pad_pid    = File.open!(String.duplicate("\x00", pad_length), [:ram, :binary])
    target_pid = File.open!("", [:ram, :binary, :write, :read])

    Nitroglycerin.encrypt(source_pid, pad_pid, target_pid)

    :file.position(target_pid, :bof)

    # Magic bytes
    assert IO.binread(target_pid, 2) == "NG"

    # Pad index
    << index :: unsigned-little-64 >> = IO.binread(target_pid, 8)
    assert rem(index, pad_length) == 0

    # Checksum
    assert IO.binread(target_pid, 16) == :crypto.hash(:md5, content)

    # Encrypted content (should be the same as content as the pad is 0s)
    assert IO.binread(target_pid, 7) == content
  end
end
