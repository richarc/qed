defmodule QED.QubitTest do
  use ExUnit.Case
  doctest QED.Qubit

  alias QED.Qubit

  test "new/0 creates a qubit in the |0> state" do
    assert Qubit.new() == Qubit.ket0()
  end

  test "ket0/0 returns the |0> state vector" do
    assert Qubit.ket0() == Nx.tensor([Complex.new(1, 0), Complex.new(0, 0)])
  end

  test "ket1/0 returns the |1> state vector" do
    assert Qubit.ket1() == Nx.tensor([Complex.new(0, 0), Complex.new(1, 0)])
  end
end
