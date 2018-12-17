defmodule Saga do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Logger.info("[saga] start")

    # Define workers and child supervisors to be supervised
    children = [
      worker(Saga.Xmpp, []),
    ]
    opts = [strategy: :one_for_one, name: Saga.Supervisor]

    Saga.Auth.Backend.init()
    Supervisor.start_link(children, opts)
  end

end
