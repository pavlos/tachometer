defmodule Tachometer.Supervisor do
  import Supervisor.Spec

  def start_link(poll_interval) do
    children = [
      worker(Tachometer, []),
      worker(Tachometer.SchedulerUsageEventManager, []),  #todo re-evaluate rest-for-one strategy, maybe use :one_for_all
      worker(Tachometer.SchedulerPoller, [poll_interval])
    ]

    Supervisor.start_link(children, strategy: :rest_for_one, name: __MODULE__)
  end

  def supervise_event_handler(manager, handler_module) do
    watcher_spec = worker(Watcher, [manager, handler_module, []], [id: handler_module])
    Supervisor.start_child __MODULE__, watcher_spec
  end

  def terminate_event_handler(handler_module) do
    Supervisor.terminate_child __MODULE__, handler_module
  end

  def delete_event_handler(handler_module) do
    Supervisor.delete_child __MODULE__, handler_module
  end

  def stop do
    Supervisor.stop(__MODULE__, :normal)
  end

end
