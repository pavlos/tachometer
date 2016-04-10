defmodule Tachometer.SchedulerUsageEvent.Manager do
  def start_link do
    GenEvent.start_link name: __MODULE__
  end

  def notify(scheduler_usage) do
    GenEvent.notify __MODULE__, {:scheduler_usage_update, scheduler_usage}
  end

  def which_handlers do
    GenEvent.which_handlers __MODULE__
  end

end
