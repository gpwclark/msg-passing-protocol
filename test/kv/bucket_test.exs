defmodule KV.BucketTest do
  use ExUnit.Case, async: true
  require Logger

  setup do
    bucket = start_supervised!(KV.Bucket)
    Logger.info("Begin bucket test setup. #{inspect(bucket)}")
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    IO.puts("Begin bucket test")
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3

    the_val = KV.Bucket.delete(bucket, "milk")
    IO.puts("hello val: #{the_val}")
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
