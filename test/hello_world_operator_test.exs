defmodule HelloWorldOperatorTest do
  use ExUnit.Case
  doctest HelloWorldOperator

  test "greets the world" do
    assert HelloWorldOperator.hello() == :world
  end
end
