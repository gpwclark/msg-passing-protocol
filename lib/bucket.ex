defmodule KV.Bucket do
  use Agent, restart: :temporary
  require Logger

  @moduledoc """
  bucket that contains a tuple
  """

  @doc """
  Make a new bucket.
  """
  def start_link(opts) do
    Logger.info("self: #{inspect(self())} Start bucket with opts: #{inspect(opts)}")
    Agent.start_link(fn -> %{:tup => {}} end)
  end

  @doc """
  Puts `val` in `bucket` indexed by `key`
  """
  def put(bucket, val) do
    Agent.update(bucket, fn m -> %{m | :tup => Tuple.append(m.tup, val)} end)
  end

  @doc """
  Get a value from `bucket` by `key`
  """
  def get(bucket, idx) do
    Agent.get(bucket, fn m -> elem(m.tup, idx) end)
  end
end
