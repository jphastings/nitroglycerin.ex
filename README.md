# Nitroglycerin

Nitroglycerin is a library for [One-Time Pad cryptography](https://en.wikipedia.org/wiki/One-time_pad). Assuming you keep your pad a secret, this library will help you encrypt your files in a way that's provably impossible to crack.

## Installation

[Available in Hex](https://hex.pm/packages/nitroglycerin), the package can be installed with:

  1. Add `nitroglycerin` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:nitroglycerin, "~> 0.2.2"}]
    end
    ```

  2. Ensure `nitroglycerin` is started before your application:

    ```elixir
    def application do
      [applications: [:nitroglycerin]]
    end
    ```

## EScripts

### Use

You can encrypt a file with the command line script like this:

```bash
$ nitroglycerin e file.txt random.pad file.txt.nitro
$ nitroglycerin d file.txt.nitro random.pad file.txt.decrypted
```

*NB.* The output of this command is non-deterministic and you will use up a portion of your pad file with each execution.

### Installation

You can install the helper escript from within the repo folder with:

```bash
mix escript.build
mix escript.install
```

If you are using Elixir 1.4, you can install the Nitroglycerin EScript with:

```bash
mix escript.install hex nitroglycerin
```
