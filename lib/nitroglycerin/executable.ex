defmodule Nitroglycerin.Executable do
  def main(argv) do
    case argv do
      ["e", source, pad] -> encrypt(source, pad)
      _ -> IO.puts :stderr, "Invalid options"
    end
  end

  defp encrypt(source_path, pad_path) do
    case File.open(source_path) do
      {:ok, source_pid} ->
        Nitroglycerin.encrypt!(source_pid, pad_path, "#{source_path}.nitro")
      {:error, reason} ->
        IO.puts :stderr, "(#{reason}) Could not open source: #{source_path}"
    end
  end
end
