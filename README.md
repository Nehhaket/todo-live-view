# Setup

## Installation
1. Install `postgresql`
2. Install `asdf` ([guide](https://asdf-vm.com/guide/getting-started.html#_3-install-asdf))
3. Install `erlang` and `elixir` plugins for `asdf` with `$ asdf plugin add erlang && asdf plugin add elixir`
4. Install `elixir` and `erlang` with `$ asdf install` 

## Starting server locally
  * Setup DB connection in `config/dev.exs`
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4001`](https://localhost:4001) from your browser.
