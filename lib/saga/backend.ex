defmodule Saga.Backend do
    defmacro __using__(_data) do
        quote do
            require Saga.Backend
            import Saga.Backend, only: [backend_fun: 2, backend_cfg: 1]

            defmacro __using__(_opts) do
                quote do
                    require Logger
                end
            end
        end
    end

    defmacro backend_cfg(option) do
        quote do
            defp backend() do
                Application.get_env(:saga, unquote(option), @default_backend)
            end

            def init() do
                apply(backend(), :init, [])
            end
        end
    end

    defmacro backend_fun(name, args) do
        quote do
            def unquote(name)(unquote_splicing(args)) do
                apply(backend(), unquote(name), unquote(args))
            end
        end
    end
end
