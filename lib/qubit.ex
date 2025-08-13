defmodule QED.Qubit do
  @moduledoc """
  Represents a quantum qubit.
  """

  defstruct [:state]

  # @type t :: %__MODULE__{state: Nx.Tensor.t()}

  @doc """
  Creates a new qubit in the |0> state.
  """
  def new() do
    %__MODULE__{state: Nx.tensor([c(1), c(0)])}
  end

  @doc """
  Creates a new qubit with the given complex amplitudes.
  """
  def new(alpha, beta) do
    %__MODULE__{state: Nx.tensor([alpha, beta])}
  end

  @doc """
  Sets the qubit state to |1>.
  """
  def ket1(%__MODULE__{}) do
    %__MODULE__{state: Nx.tensor([c(0), c(1)])}
  end

  @doc """
  Checks if the qubit state is normalized.
  """
  def normalized?(%QED.Qubit{state: state}) do
    # A qubit is normalized if the sum of the squares of the absolute values of its amplitudes is equal to 1.
    Kernel.abs(Nx.to_number(Nx.sum(Nx.pow(Nx.abs(state), 2))) - 1) < 1.0e-7
  end

  defp c(real) do
    Complex.new(real, 0)
  end
end
