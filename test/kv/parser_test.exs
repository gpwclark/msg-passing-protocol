defmodule Parser.Test do
  use ExUnit.Case, async: true
  require Logger

  test "test rudimentary json stream parser" do
    json_in = "{ok: some json}"
    binary_data_in = "lkjasdlkfjdk"
    all = json_in <> binary_data_in
    {json, binary_data} = KV.Parser.parse(all, <<>>, :begin)
    assert json == json_in
    assert binary_data == binary_data_in
  end
end

