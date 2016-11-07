defmodule Nitroglycerin.State do
  @moduledoc """
  A struct for storing all the transient aspects of encrypting or decrypting with a pad.
  """
  defstruct [:target_io, :bytes_used, :digest]
end
