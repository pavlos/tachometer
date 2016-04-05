defmodule Tachometer.SchedulerPoller do
  require Logger

  def start_link(poll_interval) do
    :erlang.system_flag(:scheduler_wall_time, true)
    initial_reading = :erlang.statistics(:scheduler_wall_time)
    pid = spawn_link(__MODULE__, :poll, [poll_interval, initial_reading])
    unregister()
    true = Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  defp unregister do
    if Process.whereis(__MODULE__), do: Process.unregister(__MODULE__)
  end

  def stop do
    unregister
    :erlang.system_flag(:scheduler_wall_time, false)
  end

  def poll(interval, first) do
    receive do
      {:set_poll_interval, new_interval} ->
        interval = new_interval
      message ->
        Logger.warn "received unexpected message #{inspect message}"
    after
      interval -> :ok
    end
    last = :erlang.statistics(:scheduler_wall_time)
    spawn_link fn->
      __scheduler_usage(first, last) |> update_tachometer
    end
    poll(interval, last)
  end

  def below_max? do
    first = :erlang.statistics(:scheduler_wall_time)
    last = :erlang.statistics(:scheduler_wall_time)
    __scheduler_usage(first, last) < 1.0
  end

  def set_poll_interval(interval) do
    send __MODULE__, {:set_poll_interval, interval}
    :ok
  end

  def __scheduler_usage(first, last) do
    {last_active,  last_total}  = reduce_sample(last)
    {first_active, first_total} = reduce_sample(first)
    (last_active - first_active)/(last_total - first_total)
  end

  defp update_tachometer(usage) do
    Agent.cast Tachometer, fn(_old_usage)-> usage end
  end

  defp reduce_sample(sample) do
    sample |>
    Enum.reduce({0,0},
      fn({_scheduler, active_time, total_time}, {total_active, total_total}) ->
        {active_time + total_active, total_time + total_total}
      end
    )
  end

end
