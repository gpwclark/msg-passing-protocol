defmodule KV.Bucket do
  use Agent, restart: :temporary
  require Logger

  @moduledoc """
  bucket that contains a map
  """

  @doc """
  Make a new bucket.
  """
  def start_link(opts) do
    Logger.info("self: #{inspect(self())} Start bucket with opts: #{inspect(opts)}")
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Puts `val` in `bucket` indexed by `key`
  """
  def put(bucket, key, val) do
    Agent.update(bucket, &Map.put(&1, key, val))
  end

  @doc """
  Get a value from `bucket` by `key`
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Removes `key` from `bucket`,
  returning current val of key if it exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn dict ->
      Map.pop(dict, key)
    end)
  end
end
