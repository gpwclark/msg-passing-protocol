defmodule KV.Registry do
  use GenServer, restart: :permanent, type: :worker, shutdown: 5000
  require Logger

  @moduledoc """
  Registry that holds active buckets.
  """

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
#    Logger.info("self: #{inspect(self())} KV.Registry GenServer.startLink opts #{inspect(opts)}")
#    # 1. Pass the name to GenServer's init
#    server = Keyword.fetch!(opts, :name)
#    {status, pid} = GenServer.start_link(__MODULE__, server, opts)
#    Logger.info("self: #{inspect(self())} Gen server status: #{inspect(status)} , pid: #{inspect(pid)}")
#    _ref = Process.monitor(pid)
#    {status, pid}
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Look up bucket pid with given `name` from `server`.
  Returns {:ok pid} if exists and {:error} otherwise.
  """
  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures `bucket` with `name` exists.
  """
  def create(server, name) do
    Logger.info("self: #{inspect(self())} cast to #{name} on server: #{inspect(server)}")
    GenServer.call(server, {:create, name})
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    Logger.info("self: #{inspect(self())} stop server")
    GenServer.stop(server)
  end

  ##Server Callbacks

  def terminate(reason, state) do
    Logger.info("self: #{inspect(self())} Oh no!, going down.")
  end

  def init(table) do
    Logger.info("self:  #{inspect(self())} Alive for now.")
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs  = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}
      :error ->
        Logger.info("self: #{inspect(self())} Creating bucket.")
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    Logger.info("Down down #{inspect(ref)}")
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    Logger.info("Fall thru")
    {:noreply, state}
  end
end
