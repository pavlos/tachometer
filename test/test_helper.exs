ExUnit.start()

try do
  Tachometer.stop
catch
  :exit, :noproc -> IO.puts "caught noproc"
end
