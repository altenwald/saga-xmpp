defmodule Saga.Auth.Backend.Postgresql do
    use Saga.Auth.Backend

    @moduledoc """
    Backend to use PostgreSQL for authentication purposes.
    """

    @conn :saga_auth

    def init() do
        Logger.info("[auth] [postgresql] initiated")
    end

    def check(user, pass) do
        query =
            """
            SELECT id
            FROM users
            WHERE username = $1
            AND password = MD5($2)
            """
        case DBI.do_query(@conn, query, [user, pass]) do
            {:ok, 1, [{id}]} ->
                Logger.info "[auth] access granted for #{user}"
                {:ok, id}
            _ ->
                Logger.error "[auth] access denied for #{user}"
                Logger.debug "[auth] invalid pass: #{pass}"
                {:error, :enotfound}
        end
    end

    def get_id(user) do
        query =
            """
            SELECT id
            FROM users
            WHERE username = $1
            """
        case DBI.do_query(@conn, query, [user]) do
            {:ok, 1, [{id}]} -> id
            _ -> nil
        end
    end

end
