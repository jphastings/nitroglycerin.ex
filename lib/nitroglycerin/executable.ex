defmodule Nitroglycerin.Executable do
  @moduledoc false

  def main(argv) do
    case argv do
      ["e", source, pad] -> encrypt(source, pad)
      ["d", source, pad] -> decrypt(source, pad)
      _ -> IO.puts :stderr, "Invalid options"
    end
  end

  defp encrypt(source_path, pad_path) do
    case File.open(source_path) do
      {:ok, source_io} ->
        Nitroglycerin.encrypt!(
          source_io,
          Nitroglycerin.Pad.from_path(pad_path),
          File.open!("#{source_path}.nitro", [:write, :binary])
        )
      {:error, reason} ->
        IO.puts :stderr, "(#{reason}) Could not open source: #{source_path}"
    end
  end

  defp decrypt(source_path, pad_path) do
    case File.open(source_path) do
      {:ok, source_io} ->
        target_path = String.replace(source_path, ~r/\.nitro\Z/, "")
        target_path = if source_path == target_path do
          "#{source_path}.decrypted"
        else
          target_path
        end

        try do
          Nitroglycerin.decrypt!(
            source_io,
            Nitroglycerin.Pad.from_path(pad_path),
            File.open!(target_path, [:write, :binary])
          )
        rescue
          e in Nitroglycerin.Errors.IncorrectPad ->
            File.rm!(target_path)
            IO.puts :stderr, e.message
        end
      {:error, reason} ->
        IO.puts :stderr, "(#{reason}) Could not open source: #{source_path}"
    end
  end
end
