defmodule BeansTest do
  use ExUnit.Case
  doctest Beans

  test "greets the world" do
    assert Beans.hello() == :world
  end
end
