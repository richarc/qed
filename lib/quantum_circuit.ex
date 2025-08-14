defmodule QED.QuantumCircuit do
  @moduledoc """
  Represents a quantum circuit, holding its qubits, classical bits, state vector,
  and a list of instructions to be applied.
  """

  alias QED.Qubit
  alias QED.Qmath

  defstruct [:qubits, :classical_bits, :state_vector, :instructions]

  @doc """
  Creates a new quantum circuit with the specified number of qubits and classical bits.

  Initializes all qubits to the |0> state, classical bits to 0, and computes the
  initial state vector as the tensor product of all qubit states.
  The number of qubits and cbits must be greater than or equel to 1
  """
  def new(num_qubits \\ 1, num_classical_bits \\ 1)
      when is_integer(num_qubits) and num_qubits >= 1 and
             is_integer(num_classical_bits) and num_classical_bits >= 1 do
    qubits = for _ <- 1..num_qubits, do: Qubit.new()
    classical_bits = for _ <- 1..num_classical_bits, do: 0
    state_vector = calculate_initial_state_vector(qubits)
    instructions = []

    %__MODULE__{
      qubits: qubits,
      classical_bits: classical_bits,
      state_vector: state_vector,
      instructions: instructions
    }
  end

  defp calculate_initial_state_vector(qubits) do
    i = Nx.tensor([1])
    Enum.reduce(qubits, i, fn x, acc -> Qmath.kronecker_product(x, acc) end)
  end
end
