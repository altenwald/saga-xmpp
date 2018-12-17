use Mix.Config

config :logger, backends: [:console]

config :logger, :console,
       level: :debug,
       format: "$time $metadata[$level] $levelpad$message\n",
       metadata: [:pid]

File.rm_rf "test/db"

config  :saga,
        port: 5222,
        domains: ["altenwald.com"],
        auth_backend: Saga.Auth.Backend.Dummy,
        tls_key_file: "config/server.key",
        tls_cert_file: "config/server.crt"
