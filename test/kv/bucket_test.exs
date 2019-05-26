defmodule KV.BucketTest do
  use ExUnit.Case, async: true
  require Logger

  setup do
    bucket = start_supervised!(KV.Bucket)
    Logger.info("Begin bucket test setup. #{inspect(bucket)}")
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    Logger.info("Begin bucket test")
    KV.Bucket.put(bucket, "milk")
    assert KV.Bucket.get(bucket, 0) == "milk"
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
