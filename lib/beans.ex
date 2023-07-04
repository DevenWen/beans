defmodule Beans do
  @moduledoc """
  Documentation for `Beans`.
  """

  use Beans.Type

  @doc """

    Beans.call ->
      1. 根据 cluster_name 找到一致性 Hash 环
      2. 根据 address 找到对应的节点
      3. 调用节点的 server router
      4. router 在本地调用对应的 server (按需构建进程)

  """

  @spec call(cluster_name(), address(), term()) :: :ok
  def call(_cluster_name, _aim, _message) do
    :TODO
  end
end
