defmodule NitroglycerinTest do
  use ExUnit.Case
  doctest Nitroglycerin

  test "golden path encryption" do
    content = "Content"
    pad = String.duplicate("\x00", 64)
    pad_length = String.length(pad)

    pad_path = "test.pad"
    File.rm("#{pad_path}.useage")
    target_path = "test.nitro"
    source_pid = File.open!(content, [:ram, :binary])
    File.write!(pad_path, pad)

    Nitroglycerin.encrypt!(source_pid, pad_path, target_path)

    target_pid = File.open!(target_path, [:read, :binary])

    # Magic bytes
    assert IO.binread(target_pid, 2) == "NG"

    # Pad index
    <<index :: unsigned-little-64>> = IO.binread(target_pid, 8)
    assert rem(index, pad_length) == 0

    # Encrypted content (should be the same as content as the pad is 0s)
    assert IO.binread(target_pid, String.length(content)) == content

    # Checksum
    assert IO.binread(target_pid, :all) == :crypto.hash(:md5, content)
  end
end
