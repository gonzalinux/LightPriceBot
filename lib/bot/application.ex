defmodule Bot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExGram, # This will setup the Registry.ExGram
    {Bot.LightPriceBot, [method: :polling, token: "5516469981:AAFJQ12dtjEgI0xPUjFi71rHLGzKnRAyg8M"],}, 
    {GetHoras,:pidHoras},
    {Subs, :pidSubs},
    {Scheduler, {:pidHoras,:pidSubs}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
