defmodule Beans.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      Beans.Cluster.child_spec(on_connect: &on_connect/2, on_disconnect: &on_disconnect/2),
      {Cluster.Supervisor, [topologies, [name: Beans.ClusterSupervisor]]}
    ]

    opts = [strategy: :one_for_one, name: Beans.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def on_connect(node, _current_nodes) do
    Logger.info("Node #{inspect(node)} connected")
    :ok
  end

  def on_disconnect(node, _current_nodes) do
    Logger.info("Node #{inspect(node)} disconnected")
    :ok
  end
end
