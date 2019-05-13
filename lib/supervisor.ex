defmodule KV.Supervisor do
  use Supervisor
  require Logger

  @moduledoc """
  Supervisor responsible for maintaining registry.
  """

  def start_link(opts) do
    opts = [[debug: [:log]] | opts]
    Logger.info("self: #{inspect(self())} Regisgry/bucket supervisor opts #{inspect(opts)}")
    {x, pid} = Supervisor.start_link(__MODULE__, :ok, opts)
    Logger.info("self: #{inspect(self())} started Registry/bucket supervisor #{inspect(pid)}, status: #{inspect(x)}")
    {x, pid}
  end

  def init(:ok) do
    children = [
      {Task.Supervisor, name: KV.ServerSupervisor},
      #for pub
      Supervisor.child_spec({Task, fn -> KV.Server.start_recv(8787) end}, restart: :transient, id: "PublicationServer"),
      #TODO Supervisor.child_spec({Task, fn -> KV.Server.start_recv(7878, :sub) end}, restart: :transient, id: "SubscriptionServer"),
      # {Task, fn -> KV.Server.start_recv(8787) end},
      #for sub
      #Supervisor.child_spec({Task, fn -> KV.Server.start_recv(7878) end}, restart: :permanent, id: "SubServer"),
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      #registry of buckets. buckets are where all the publications go.
      #subscribers. like. buckets.
      {KV.Registry, name: KV.Registry}
    ]

    Logger.info("self: #{inspect(self())} init children: #{inspect(children)}")
    Supervisor.init(children, strategy: :one_for_all)
  end
end
