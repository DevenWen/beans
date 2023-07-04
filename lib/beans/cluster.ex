defmodule Beans.Cluster do
  require Logger
  use GenServer

  @default_interval_check 1_000

  defstruct current_nodes: [], on_connect: nil, on_disconnect: nil, interval_check: 1

  # API
  def on_connect(node), do: GenServer.call(__MODULE__, {:connect, node})
  def on_disconnect(node), do: GenServer.call(__MODULE__, {:disconnect, node})
  def list_nodes(), do: GenServer.call(__MODULE__, :list_nodes)

  # Callback
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    current_nodes = Node.list(:connected)

    interval_check =
      Keyword.get(opts, :interval_check, @default_interval_check)
      |> Kernel.min(1_000)

    state = %__MODULE__{
      current_nodes: current_nodes,
      interval_check: interval_check,
      on_connect: Keyword.get(opts, :on_connect, fn _, _ -> :ok end),
      on_disconnect: Keyword.get(opts, :on_disconnect, fn _, _ -> :ok end)
    }

    Process.send_after(self(), :check, interval_check)
    {:ok, state}
  end

  def handle_info(:check, state) do
    current_nodes = Node.list(:connected)
    disconnected_nodes = state.current_nodes -- current_nodes

    state =
      Enum.reduce(disconnected_nodes, state, fn node, state ->
        {:reply, _, state} = handle_call({:disconnect, node}, nil, state)
        state
      end)

    Process.send_after(self(), :check, state.interval_check)
    {:noreply, state}
  end

  def handle_call(:list_nodes, _from, %__MODULE__{current_nodes: current_nodes} = state) do
    {:reply, current_nodes, state}
  end

  def handle_call(
        {:connect, node},
        _from,
        %__MODULE__{on_connect: on_connect_fn, current_nodes: current_nodes} = state
      ) do
    with true <- Node.connect(node),
         :ok <- on_connect_fn.(node, current_nodes) do
      {:reply, true, %__MODULE__{state | current_nodes: [node | current_nodes]}}
    else
      others ->
        Logger.warn("Couldn't connect to node #{inspect(node)}, reason: #{inspect(others)}")
        {:reply, false, state}
    end
  end

  def handle_call(
        {:disconnect, node},
        _from,
        %__MODULE__{on_disconnect: on_disconnect_fn, current_nodes: current_nodes} = state
      ) do
    with :ok <- on_disconnect_fn.(node, current_nodes) do
      {:reply, true, %__MODULE__{state | current_nodes: List.delete(current_nodes, node)}}
    else
      others ->
        Logger.warn("Couldn't disconnect to node #{inspect(node)}, reason: #{inspect(others)}")
        {:reply, false, state}
    end
  end
end
