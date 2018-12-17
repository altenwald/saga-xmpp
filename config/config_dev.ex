use Mix.Config

config :logger,
    backends: [
        :console,
        {LoggerFileBackend, :file},
        # {Logger.Backends.Syslog, :syslog}
    ]

config :logger, :console,
    level: :debug,
    format: "$time $metadata[$level] $levelpad$message\n",
    metadata: [:pid]

config :logger, :file,
    level: :info,
    format: "$date $time $metadata[$level] $levelpad$message\n",
    metadata: [:pid],
    path: "log/saga.log"

# config :logger, :syslog,
#     level: :info,
#     facility: :mail,
#     appid: "saga",
#     host: "127.0.0.1",
#     port: 514

config  :dbi,
        saga_auth: [
          type: :pgsql,
          host: 'localhost',
          user: 'saga',
          pass: 'saga',
          database: 'saga',
          port: 5432,
          poolsize: 10
        ]

config  :saga,
        # port to listen for clients
        port: 5222,
        # XMPP valid domains
        domains: [
          "altenwald.com"
        ],
        # type of database for auth backend
        # it should be one of those:
        # - Saga.Auth.Backend.Postgresql
        auth_backend: Saga.Auth.Backend.Postgresql,

        # TLS info
        tls_key_file: "config/server.key",
        tls_cert_file: "config/server.crt"
