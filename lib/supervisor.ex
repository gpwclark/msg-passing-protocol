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
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {KV.Registry, name: KV.Registry}
    ]

    Logger.info("self: #{inspect(self())} init children: #{inspect(children)}")
    Supervisor.init(children, strategy: :one_for_all)
  end
end
