# Nitroglycerin

Nitroglycerin is a library for [One-Time Pad cryptography](https://en.wikipedia.org/wiki/One-time_pad). Assuming you keep your pad a secret, this library will help you encrypt your files in a way that's provably impossible to crack.

## Installation

[Available in Hex](https://hex.pm/packages/nitroglycerin), the package can be installed with:

  1. Add `nitroglycerin` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:nitroglycerin, "~> 0.1.1"}]
    end
    ```

  2. Ensure `nitroglycerin` is started before your application:

    ```elixir
    def application do
      [applications: [:nitroglycerin]]
    end
    ```

