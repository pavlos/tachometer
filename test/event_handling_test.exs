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

  test "handler receives correct scheduler usage" do

  end

  test "every time scheduler usage is updated an event is emitted"

  test "event handler gets called" do
    self |> TestHandlerMacro.create_test_handler

    SchedulerUsageEventManager.add_handler(TestSchedulerUsageEventHandler)
    on_exit fn ->
      try do
        SchedulerUsageEventManager.delete_handler(TestSchedulerUsageEventHandler)
      catch
        :exit, _ -> :ok
      end
    end
    assert_receive :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler, @poll_interval + 5
    SchedulerUsageEventManager.delete_handler(TestSchedulerUsageEventHandler)
    refute_receive :event_reveived, @poll_interval * 3
  end

end
