defmodule EventHandlingTest do
  use ExUnit.Case, async: false
  alias Tachometer.SchedulerUsageEventManager
  require TestHandlerMacro

  @poll_interval 30

  setup_all do
    :timer.sleep 10
    {:ok, _pid} = Tachometer.start @poll_interval
    {:ok, []}
  end

  setup do
    on_exit fn ->
      SchedulerUsageEventManager.which_handlers |>
      Enum.map(&SchedulerUsageEventManager.delete_handler/1)
    end
  end

  test "handler receives correct scheduler usage" do
    defmodule TestHandlerUsage do
      use Tachometer.SchedulerUsageEventHandler

      def handle_scheduler_usage_update(usage) do
        assert usage == Tachometer.read()
      end
    end

    SchedulerUsageEventManager.add_handler(TestHandlerUsage)
    :timer.sleep @poll_interval * 3
  end

  test "event handler gets called" do
    self |>
    TestHandlerMacro.create_test_handler(TestHandlerCalled) |>
    SchedulerUsageEventManager.add_handler

    assert_receive :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler, @poll_interval + 5
    SchedulerUsageEventManager.delete_handler(TestSchedulerUsageEventHandler)
    refute_receive :event_reveived, @poll_interval * 3
  end

end
