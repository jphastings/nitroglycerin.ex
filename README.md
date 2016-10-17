# Nitro

Nitro is a library for [One-Time Pad cryptography](https://en.wikipedia.org/wiki/One-time_pad). Assuming you keep your pad a secret, this library will help you encrypt your files in a way that's provably impossible to crack.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `nitro` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:nitro, "~> 0.1.0"}]
    end
    ```

  2. Ensure `nitro` is started before your application:

    ```elixir
    def application do
      [applications: [:nitro]]
    end
    ```

