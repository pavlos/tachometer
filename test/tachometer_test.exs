defmodule TachometerTest do
  use ExUnit.Case, async: false

  @poll_interval 20
  @wait_interval (@poll_interval * 3)

  setup do
    :timer.sleep 10
    {:ok, _pid} = Tachometer.start @poll_interval
    {:ok, []}
  end

  test "doing nothing gives a reading close to 0" do
    wait
    reading = Tachometer.read
    reading |> assert_in_delta(0, 0.02)
  end

  test "peg one scheduler" do
    spawn_link fn-> fib_calc(100) end
    wait
    reading = Tachometer.read
    expected_reading = 1/(:erlang.system_info(:schedulers))
    reading |> assert_in_delta(expected_reading, 0.02)
  end

  test "peg several schedulers" do
    total_schedulers = :erlang.system_info :schedulers

    for n <- 1..total_schedulers do
      pids = for _ <- 1..n, do: spawn fn-> fib_calc(100) end
      try do
        wait
        expected_reading = n/(:erlang.system_info(:schedulers))
        reading = Tachometer.read
        reading |> assert_in_delta(expected_reading, 0.02)
      after
        pids |> Enum.map(fn(p)-> p |> Process.exit(:kill) end)
      end
    end
  end

  test "waiting on network IO gives low reading" do
    wait
    test_listen
    wait
    reading = Tachometer.read
    reading |> assert_in_delta(0, 0.01)
  end

  test "update polling interval from long to short happens instantly" do
    Tachometer.set_poll_interval :infinity

    wait
    reading0 = Tachometer.read
    wait
    reading1 = Tachometer.read
    wait
    wait
    reading2 = Tachometer.read

    assert reading0 == reading1
    assert reading1 == reading2

    Tachometer.set_poll_interval @poll_interval
    wait
    reading3 = Tachometer.read
    refute reading0 == reading3
  end

  test "computes scheduler usage correctly" do
    first = [{4, 1000, 5000}, {2, 1500, 5000}, {7, 5000, 5000}, # = 7500/15000
             {5, 2000, 5000}, {6, 3000, 5000}, {3, 5000, 5000}, # = 10000/15000
             {8, 0, 5000}, {1, 4000, 5000}]                     # = 4000/10000
    # = 21500/40000

    last = [{5, 4000, 10000}, {3, 9000, 10000}, {4, 6000, 10000}, # = 19000/30000
            {7, 10000, 10000}, {2, 1500, 10000}, {6, 4500, 10000},# = 16000/30000
            {1, 4500, 10000}, {8, 2000, 10000}]                   # = 6500/20000
    #= 41500/80000

    actual = Tachometer.SchedulerPoller.__scheduler_usage first, last
    expected = 20000/40000
    assert actual == expected
  end

  test "stop tachometer" do
    Tachometer.stop
    assert {:noproc, _} = catch_exit(Tachometer.read)
  end

  defp wait do
    :timer.sleep @wait_interval
  end

  defp test_listen do
    (9500..10499) |>
    Enum.map(fn(port)->
      spawn_link fn ->
        {:ok, listenSocket} = :gen_tcp.listen(port, [{:active, true}, :binary])
        {:ok, _acceptSocket} = :gen_tcp.accept(listenSocket)
      end
    end)
  end

  # super inefficient, on purpose
  defp fib_calc(0), do: 0
  defp fib_calc(1), do: 1
  defp fib_calc(n), do: fib_calc(n-1) + fib_calc(n-2)

end
