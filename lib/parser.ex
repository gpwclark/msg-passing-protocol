defmodule KV.Parser do
  require Logger

  @moduledoc """
  primitive json stream parser
  """

  @doc """
  parses non nested json object from following binary data,
  e.g. {json stuff}binary data
  """
  def parse(<<byte::size(8), data::binary>>, current, state) do
    case state do
      :begin ->
        parse(data, current <> <<byte>>, :json)
      :json when byte != 125 ->
        parse(data, current <> <<byte>>, :json)
      :json ->
        {current <> <<byte>>, data}
      _ ->
        Logger.info("This is bad.")
    end
  end
end
