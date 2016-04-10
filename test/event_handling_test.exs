defmodule EventHandlingTest do
  use ExUnit.Case, async: false
  alias Tachometer.SchedulerUsageEventManager
  require TestHandlerMacro
  import ExUnit.CaptureLog


  @poll_interval 30
  @receive_wait @poll_interval + 5

  setup_all do
    :timer.sleep 10
    {:ok, _pid} = Tachometer.start @poll_interval
    {:ok, []}
  end

  setup do
    on_exit fn ->
      SchedulerUsageEventManager.which_handlers |>
      Enum.map(&Tachometer.remove_scheduler_usage_handler/1)
      flush()
    end
  end

  test "handler receives correct scheduler usage" do
    defmodule TestHandlerUsage do
      use Tachometer.SchedulerUsageEventHandler

      def handle_scheduler_usage_update(usage) do
        assert usage == Tachometer.read()
      end
    end

    {:ok, _handler} = Tachometer.add_scheduler_usage_handler(TestHandlerUsage)
    :timer.sleep @poll_interval * 3
  end

  test "event handler gets called and then deleted" do
    handler_name = TestHandlerCalled
    {:ok, _handler} = create_messaging_handler(handler_name)

    assert_receive :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler, @receive_wait
    :ok = Tachometer.remove_scheduler_usage_handler handler_name
    assert [] == Tachometer.SchedulerUsageEventManager.which_handlers
    refute_receive :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler, @receive_wait
  end

  test "that handlers can survive an event manager crash" do
    capture_log fn ->
      {:ok, _handler} = create_messaging_handler(TestHandlerManagerKill)
      pid = Process.whereis(Tachometer.SchedulerUsageEventManager)

      # crash the event manager
      Process.exit(pid, :kill)
      :timer.sleep 10

      assert [TestHandlerManagerKill] == Tachometer.SchedulerUsageEventManager.which_handlers
      assert_receive :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler, @receive_wait
    end
  end

  test "that handlers can survive a bad notify" do
    {:ok, _handler} = create_messaging_handler(TestHandlerBadNotify)
    GenEvent.notify(Tachometer.SchedulerUsageEventManager, :bogus_event)
    flush()
    assert_receive :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler, @receive_wait
  end

  test "that handlers can survive a bad call" do
    {:ok, _handler} = create_messaging_handler(TestHandlerBadCall)
    GenEvent.call(Tachometer.SchedulerUsageEventManager, TestHandlerBadCall, :bogus_call)
    flush()
    assert_receive :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler, @receive_wait
  end

  defp create_messaging_handler(name) do
    {:ok, _handler} = self |>
    TestHandlerMacro.create_test_handler(name) |>
    Tachometer.add_scheduler_usage_handler
  end

  defp flush do
    receive do
      _ -> flush
    after
      0 -> :ok
    end
  end

end
