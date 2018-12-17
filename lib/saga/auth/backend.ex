defmodule Saga.Auth.Backend do

    @moduledoc """
    Backend module to let to the system use whatever implementation for auth
    in the whole system based on configuration.
    """

    @default_backend Saga.Auth.Backend.Postgresql

    use Saga.Backend

    backend_cfg :auth_backend

    @callback init() :: :ok | {:error, atom()}

    @callback check(String.t, String.t) :: {:ok, integer()} | {:error, atom()}
    backend_fun :check, [user, password]

    @callback get_id(String.t) :: integer() | nil
    backend_fun :get_id, [user]

end
