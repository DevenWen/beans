defmodule Beans.Type do
  defmacro __using__(_) do
    quote do
      @type cluster_name :: atom()
      @type address :: binary()
    end
  end
end
