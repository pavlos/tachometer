defmodule Tachometer.SchedulerUsageEvent.Handler do
  @callback handle_scheduler_usage_update(number) :: any

  defmacro __using__(_opts) do
    quote do
      @behaviour Tachometer.SchedulerUsageEvent.Handler
      use GenEvent
      require Logger

      def handle_event({:scheduler_usage_update, usage}, state) do
        handle_scheduler_usage_update(usage)
        {:ok, state}
      end

      def handle_event(unexpected, state) do
        Logger.info(
          "unexpected event recived: #{inspect unexpected}, by handler: #{inspect __MODULE__}, state: #{inspect state}"
        )
        {:ok, state}
      end

      def handle_call(unexpected, state) do
        Logger.info(
          "unexpected call recived: #{inspect unexpected}, by handler: #{inspect __MODULE__}, state: #{inspect state}"
        )
        {:ok, state, state}
      end

      defoverridable [handle_event: 2, handle_call: 2]

    end
  end
end
