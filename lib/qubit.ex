defmodule QED.Qubit do
  @moduledoc """
  Generate a quantum qubit.
  """

  @doc """
  Creates a new qubit in the |0> state.
  """
  def new() do
    ket0()
  end

  @doc """
  Sets the qubit state to |0>.
  """
  def ket0() do
    Nx.tensor([Complex.new(1, 0), Complex.new(0, 0)])
  end

  @doc """
  Sets the qubit state to |1>.
  """
  def ket1() do
    Nx.tensor([Complex.new(0, 0), Complex.new(1, 0)])
  end
end
