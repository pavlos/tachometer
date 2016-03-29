# Tachometer

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
