try do
  Tachometer.stop
catch
  :exit, :noproc -> IO.puts "caught noproc"
end


defmodule TestHandlerMacro do

  def create_test_handler(test_pid, name) do

    contents = quote bind_quoted: [test_pid: test_pid] do
      use Tachometer.SchedulerUsageEvent.Handler

      def handle_scheduler_usage_update(usage) do
        #TODO: maybe just modify SchedulerUsageEvent.Manager.add_handler to pass in test_pid as arg
        send unquote(test_pid), :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler
      end
    end

    Module.create(name, contents, Macro.Env.location(__ENV__))
    name
  end

end

ExUnit.start()

