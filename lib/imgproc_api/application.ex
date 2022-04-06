defmodule ImgprocApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ImgprocApi.Repo,
      # Start the Telemetry supervisor
      ImgprocApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ImgprocApi.PubSub},
      # Start the Endpoint (http/https)
      ImgprocApiWeb.Endpoint
      # Start a worker by calling: ImgprocApi.Worker.start_link(arg)
      # {ImgprocApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ImgprocApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ImgprocApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
