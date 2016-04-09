defmodule Tachometer.SchedulerUsageEventManager do
  def start_link do
    GenEvent.start_link name: __MODULE__
  end

  def notify(scheduler_usage) do
    GenEvent.notify __MODULE__, {:scheduler_usage_update, scheduler_usage}
  end

  def add_handler(handler) do
    GenEvent.add_handler __MODULE__, handler, nil
  end

  def delete_handler(handler) do
    GenEvent.remove_handler __MODULE__, handler, nil
  end

end
