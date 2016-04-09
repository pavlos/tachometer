try do
  Tachometer.stop
catch
  :exit, :noproc -> IO.puts "caught noproc"
end


defmodule TestHandlerMacro do

 defmacro create_test_handler(test_pid) do
    quote bind_quoted: [test_pid: test_pid] do

      defmodule TestSchedulerUsageEventHandler do
        use GenEvent

        #TODO: maybe just modify SchedulerUsageEventManager.add_handler to pass in test_pid as arg
        def handle_event({:scheduler_usage_update, _usage}, state) do
          send unquote(test_pid), :scheduler_usage_update_received_by_TestSchedulerUsageEventHandler
          {:ok, state}
        end
      end

    end
  end

end

ExUnit.start()

