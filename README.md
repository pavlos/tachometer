# Tachometer
<img align="right" src="http://i.imgur.com/HzxXvu9.png">

Easy to read, low overhead instrumentation for BEAM's schedulers in order to determine a system's capacity for efficiently performing additional work.

## Motivation

Using Unix's `rup`, `top` or Erlang's `:cpu_sup` module as a guage of BEAM's capacity
to take on more work tends to be problematic for several reasons:

* If BEAM is not the only process running on the system, `rup`, `top`, and `:cpu_sup` will report high load values even if BEAM is not doing any work.  If the intention is to have the operating system give BEAM its fair share of CPU time in relation to other processes, having BEAM back off when total system load is high may result in it being under-scheduled on a busy system - it will be too "nice".
* Even if BEAM is the only process running on a system (such as in a container), BEAM's schedulers tend to [busy wait][1] and cause `rup`, `top`, and `:cpu_sup` to report [artificially high loads][2].
* They only work on Unix, and `:cpu_sup.util` doesn't work on Mac.

Therefore, the best way to determine BEAM's capacity to take on work efficiently is to check it's scheduler usage through [`:erlang.statistics(:scheduler_wall_time)`][3] which returns the amount of time the schedulers have been active vs real time elapsed.

A scheduler is considered `active` if it is not idle and doing any of the following:
  - Executing process code
  - Executing linked-in-driver or NIF code
  - Executing built-in-functions, or any other runtime handling
  - Garbage collecting
  - Handling any other memory management

Tachometer polls the schedulers and returns their utilization ratio at any given moment.
  

## Installation
  1. Add tachometer to your list of dependencies in `mix.exs`:

        def deps do
          [{:tachometer, "~> 0.0.1"}]
        end

  2. Ensure tachometer is started before your application:

        def application do
          [applications: [:tachometer]]
        end

## Usage

`read/0` returns a float between `0` and `1` which represents fractional utilization of all schedulers.
```elixir
iex(1)> Tachometer.read
0.1250937703951221
```

Tachometer's default polling interval is 1000ms.  
`set_poll_interval/1` can be used to change the polling interval.
```elixir
# poll more often
iex(2)> Tachometer.set_poll_interval 500
:ok
```

Use `stop/0` to stop Tachometer:
```elixir
iex(3)> Tachometer.stop                  
:ok
21:54:02.679 [info]  Application tachometer exited: normal
```

`start/1` accepts `poll_interval` in milliseconds as an optional parameter.  
Defaults to `Application.get_env(:tachometer, :poll_interval)` if set, otherwise 1000ms.

```elixir
iex(4)> Tachometer.start 2000
22:07:34.147 [debug] Starting Tachometer with poll interval: 2000
{:ok, #PID<0.115.0>}
```

## Configuration

The default polling interval is 1000ms.  It can be overridden in your application's config.exs file:

```elixir
config :tachometer, poll_interval: 2000
```

## References
1. http://erlang.org/doc/man/erl.html#+sbwt
[1]: http://erlang.org/doc/man/erl.html#+sbwt

2. http://dieswaytoofast.blogspot.com/2012/09/cpu-utilization-in-erlang-r15b02.html
[2]: http://dieswaytoofast.blogspot.com/2012/09/cpu-utilization-in-erlang-r15b02.html

3. http://erlang.org/doc/man/erlang.html#statistics-1
[3]: http://erlang.org/doc/man/erlang.html#statistics-1
