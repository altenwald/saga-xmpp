defmodule Saga.Xmpp.Server do
  require Logger

  use GenStateMachine
  import Saga.Inet, only: [gethostinfo: 1]

  alias Saga.Tls
  alias :ranch, as: Ranch

  @behaviour :ranch_protocol
  @timeout 5000
  @tries 2

  defmodule StateData do
      defstruct id: nil,
                # connection
                socket: nil,
                tcp_socket: nil,
                transport: nil,
                # info for connection
                address: nil,
                remote_name: nil,
                tls: false,
                # closures
                send: nil,
                # config
                domains: [],
                tries: 0,
                # sent by client
                host: nil,
                from: nil,
                recipients: [],
                data: ""
  end

  def start_link(ref, socket, transport, _opts) do
      GenStateMachine.start_link(__MODULE__, [ref, socket, transport])
  end

  defp gen_id() do
    hashids = Hashids.new(salt: @salt,
                          min_len: @min_len,
                          alphabet: @alphabet)
    Hashids.encode(hashids, :os.system_time(:micro_seconds))
  end

  def init([ref, socket, transport]) do
      Logger.debug("[xmpp] start worker")
      domains = Application.get_env(:saga, :domains)
      send = fn(data) -> transport.send(socket, data) end
      {address, name} = gethostinfo(socket)
      id = gen_id()
      Logger.info("[xmpp] [#{id}] connected from #{address} (#{name})")
      state = %StateData{socket: socket,
                         id: id,
                         address: address,
                         remote_name: name,
                         transport: transport,
                         send: send,
                         domains: domains,
                         tries: @tries}
      actions = [{:next_event, :cast, {:init, ref}}]
      {:ok, :init, state, actions}
  end

  def init(:cast, {:init, ref}, state_data) do
    %StateData{id: id,
               socket: socket,
               transport: transport,
               hostname: hostname} = state_data
    :ok = Ranch.accept_ack(ref)
    Logger.debug ["[xmpp] [", id, "] accepted connection"]
    # transport.send(socket, error(220, nil, hostname))
    transport.setopts(socket, [{:active, :once}])
    {:next_state, :unauth, state_data}
  end

  # --------------------------------------------------------------------------
  # unauth state
  # --------------------------------------------------------------------------
  def unauth(:cast, _stanza, _state_data) do
      :keep_state_and_data
  end

  # --------------------------------------------------------------------------
  # auth state
  # --------------------------------------------------------------------------
  def auth(:cast, _stanza, _state_data) do
      :keep_state_and_data
  end

  # --------------------------------------------------------------------------
  # handle info (errors)
  # --------------------------------------------------------------------------
  def handle_event(:info, {:error, :timeout}, _state, state_data) do
      log(state_data, "[xmpp] connection close inactivity in #{@timeout}ms")
      {:stop, :normal, state_data}
  end

  def handle_event(:info, {:error, :closed}, _state, state_data) do
      log(state_data, "[xmpp] connection closed by foreign host")
      {:stop, :normal, state_data}
  end

  def handle_event(:info, {:ssl_closed, _socket}, _state, state_data) do
      log(state_data, "[xmpp] connection ssl closed by foreign host")
      {:stop, :normal, state_data}
  end

  def handle_event(:info, {:tcp_closed, _socket}, _state, state_data) do
      log(state_data, "[xmpp] connection tcp closed by foreign host")
      {:stop, :normal, state_data}
  end

  def handle_event(:info, {:error, unknown}, _state, state_data) do
      log(state_data, "[xmpp] stopping worker: #{inspect unknown}")
      {:stop, :normal, state_data}
  end

  #---------------------------------------------------------------------------
  # handle info with data state
  #---------------------------------------------------------------------------
  def handle_event(:info, {_trans, _port, newdata}, :data, state_data) do
      state_data.transport.setopts(state_data.socket, [{:active, :once}])
      {:keep_state_and_data, {:next_event, :cast, :data}}
  end

  # --------------------------------------------------------------------------
  # terminate
  # --------------------------------------------------------------------------
  def terminate(_reason, _state_name,
                %StateData{socket: socket, transport: transport}) do
      transport.close(socket)
  end

end
