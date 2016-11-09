defmodule Nitroglycerin.Errors do
  defmodule IncorrectPad do
    defexception message: "The given Pad could not successfully decrypt this file."
  end

  defmodule InvalidFile do
    defexception message: "The given file is not a Nitroglycerin encrypted file"
  end
end