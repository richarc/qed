defmodule QED.QubitTest do
  use ExUnit.Case
  doctest QED.Qubit

  alias QED.Qubit

  test "new/0 creates a qubit in the |0> state" do
    qubit = Qubit.new()
    assert qubit.state == Nx.tensor([Complex.new(1, 0), Complex.new(0, 0)])
    assert Qubit.normalized?(qubit)
  end

  test "ket1/1 sets the qubit state to |1>" do
    qubit = Qubit.new() |> Qubit.ket1()
    assert qubit.state == Nx.tensor([Complex.new(0, 0), Complex.new(1, 0)])
    assert Qubit.normalized?(qubit)
  end

  test "new/2 creates a qubit with arbitrary state" do
    alpha = Complex.new(0.6, 0.0)
    beta = Complex.new(0.8, 0.0)
    qubit = Qubit.new(alpha, beta)

    assert qubit.state == Nx.tensor([alpha, beta])
    assert Qubit.normalized?(qubit)
  end

  test "new/2 with complex numbers" do
    alpha = Complex.new(0.5, 0.5)
    beta = Complex.new(0.5, -0.5)
    qubit = Qubit.new(alpha, beta)

    assert qubit.state == Nx.tensor([alpha, beta])
    assert Qubit.normalized?(qubit)
  end

  test "normalized?/1 returns false for non-normalized state" do
    qubit = Qubit.new(Complex.new(1, 0), Complex.new(1, 0))
    refute Qubit.normalized?(qubit)
  end
end
