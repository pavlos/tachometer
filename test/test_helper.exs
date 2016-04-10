try do
  Tachometer.stop
catch
  :exit, :noproc -> IO.puts "caught noproc"
end


defmodule TestHandlerMacro do

  def create_test_handler(test_pid, name) do

    contents = quote bind_quoted: [test_pid: test_pid] do
      use GenEvent
      def handle_event({:scheduler_usage_update, _usage}, state) do
        #TODO: maybe just modify SchedulerUsageEventManager.add_handler to pass in test_pid as arg
        send unquote(test_pid), :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler
        {:ok, state}
      end
    end

    Module.create(name, contents, Macro.Env.location(__ENV__))
    name
  end

end

ExUnit.start()

