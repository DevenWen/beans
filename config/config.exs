import Config

config :libcluster,
  topologies: [
    beans: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Gossip,
      connect: {Beans.Cluster, :on_connect, []},
      disconnect: {Beans.Cluster, :on_disconnect, []},
      list_nodes: {Beans.Cluster, :list_nodes, []}
    ]
  ]
