defmodule Tachometer do
  require Logger

  def start(_type, args) do
    poll_interval = args[:poll_interval] ||  Application.get_env(:tachometer, :poll_interval)
    if poll_interval do
      start(poll_interval)
    else
      start
    end
  end

  def start(poll_interval \\ 1000) do
    Logger.info  "Starting Tachometer with poll interval: #{inspect poll_interval}"
    Tachometer.Supervisor.start_link(poll_interval)
  end

  def stop do
    Tachometer.Supervisor.stop
  end

  def start_link do
    {:ok, _pid} = Agent.start_link fn -> 0 end, name: __MODULE__
  end

  def safe_read(fallback \\ 0.50) do
    try do
      read
    catch
      _,_  ->
        Logger.warn "#{inspect __MODULE__ }.safe_read used fallback value of #{fallback}"
        fallback
    end
  end

  def read do
    Agent.get __MODULE__, fn(state)-> state end
  end

  def safe_set_poll_interval(interval) do
    try do
      set_poll_interval(interval)
    catch
      _,_ ->
        Logger.warn "#{inspect __MODULE__ }.safe_set_poll_interval failed"
    end
    :ok
  end

  def set_poll_interval(interval) do
    Tachometer.SchedulerPoller.set_poll_interval(interval)
  end

end
