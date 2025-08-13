defmodule QEDTest do
  use ExUnit.Case
  doctest QED

  test "greets the world" do
    assert QED.hello() == :world
  end
end
