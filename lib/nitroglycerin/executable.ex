defmodule Nitroglycerin.Executable do
  @moduledoc false

  def main(argv) do
    case argv do
      ["e", source, pad, out_path] -> encrypt(source, pad, out_path)
      ["d", source, pad, out_path] -> decrypt(source, pad, out_path)
      _ -> IO.puts :stderr, "Usage: nitroglycerin [e|d] source pad output"
    end
  end

  defp encrypt(source_path, pad_path, out_path) do
    case File.open(source_path) do
      {:ok, source_io} ->
        pad = Nitroglycerin.Pad.from_path(pad_path)
        %{size: source_size} = File.stat!(source_path)

        if (pad.size - pad.next_index >= source_size) do
          remains = Nitroglycerin.encrypt!(
            source_io,
            pad,
            File.open!(out_path, [:write, :binary])
          )

          IO.puts details(source_size, remains)
        else
          IO.puts :stderr, "The pad isn't large enough to encrypt this file"
        end
      {:error, reason} ->
        IO.puts :stderr, "(#{reason}) Could not open source: #{source_path}"
    end
  end

  defp decrypt(source_path, pad_path, out_path) do
    case File.open(source_path) do
      {:ok, source_io} ->
        try do
          Nitroglycerin.decrypt!(
            source_io,
            Nitroglycerin.Pad.from_path(pad_path),
            File.open!(out_path, [:write, :binary])
          )
        rescue
          e in Nitroglycerin.Errors.IncorrectPad ->
            File.rm!(out_path)
            IO.puts :stderr, e.message
        end
      {:error, reason} ->
        IO.puts :stderr, "(#{reason}) Could not open source: #{source_path}"
    end
  end

  defp details(source_size, remains) do
    count = Float.to_string(remains / source_size, decimals: 0) 
    "#{human_bytes(source_size)} encrypted.\n#{count} more similarly sized files can be encrypted."
  end

  defp human_bytes(int) do
    case int do
      n when n > 1073741824 -> "#{div(n, 1073741824)} GB"
      n when n > 1048576 -> "#{div(n, 1048576)} MB"
      n when n > 1024 -> "#{div(n, 1024)} KB"
      n -> "#{n} B"
    end
  end
end
