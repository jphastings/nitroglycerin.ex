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
        Nitroglycerin.encrypt!(
          source_io,
          Nitroglycerin.Pad.from_path(pad_path),
          File.open!(out_path, [:write, :binary])
        )
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
end
