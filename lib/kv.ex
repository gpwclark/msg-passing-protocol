defmodule KV do
  use Application #, restart: :permanent, type: :worker, shutdown: 5000
  require Logger

  @moduledoc """
  App start module
  """

  @doc """
  Starts app
  """
  def start(_type, _args) do
    Logger.info("self: #{inspect(self())} Go go KV app!")
	  {x, pid} = KV.Supervisor.start_link(name: KV.Supervisor)
    Logger.info("self: #{inspect(self())} started application KV.Supervisor #{inspect(pid)}, status: #{inspect(x)}")
    {x, pid}
  end

  def stop(state) do
    Logger.info("self: #{inspect(self())} Oh brother #{inspect(state)}")
  end
end
