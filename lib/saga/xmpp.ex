defmodule Saga.Xmpp do
  require Logger
  alias :ranch, as: Ranch

  @options [port: 5222]
  @protocol Saga.Xmpp.Server
  @ranch_handler :tcp_xmpp

  @doc """
  Wrap for start ranch listeners
  """
  def start_link(), do: start_link(@options, @protocol)

  def start_link(options, protocol) do
    options = port(options)
    Logger.info("[xmpp] starting on port #{options[:port]}")
    Ranch.start_listener(@ranch_handler, 1, :ranch_tcp, options, protocol,
                         [{:active, false}, {:packet, :raw},
                          {:reuseaddr, true}])
  end

  def stop() do
    :ok = Ranch.stop_listener(@ranch_handler)
  end

  def port(options) do
      case Application.get_env(:saga, :port, nil) do
          port when is_integer(port) -> Keyword.put(options, :port, port)
          nil -> options
      end
  end
end
