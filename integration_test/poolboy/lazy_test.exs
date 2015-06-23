defmodule Ecto.Integration.LazyTest do
  use ExUnit.Case, async: true

  require Ecto.Integration.TestPool, as: TestPool
  require Ecto.Integration.Connection, as: Connection
  alias Ecto.Adapters.Pool

  @timeout :infinity

  test "worker starts without an active connection but connects on transaction" do
    {:ok, pool} = TestPool.start_link([])
    worker = :poolboy.checkout(pool, false)
    assert Process.alive?(worker)
    refute :sys.get_state(worker).conn
    :poolboy.checkin(pool, worker)

    TestPool.transaction(pool, @timeout, fn(ref, _, _, _) ->
      assert {:ok, {Connection, conn}} = Pool.connection(ref, @timeout)
      assert Process.alive?(conn)
    end)
  end

  test "worker starts with an active connection" do
    {:ok, pool} = TestPool.start_link([lazy: false])
    worker = :poolboy.checkout(pool, false)
    assert Process.alive?(worker)
    assert :sys.get_state(worker).conn
  end
end
