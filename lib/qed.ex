defmodule QED do
  @moduledoc """
  Quantum computing simulator in Elixir.
  """

  alias QED.QuantumCircuit
  alias QED.Operators
  alias QED.Draw

  defdelegate new_circuit(num_qubits, num_classical_bits), to: QuantumCircuit, as: :new
  defdelegate x(circuit, qubit_index), to: Operators
  defdelegate y(circuit, qubit_index), to: Operators
  defdelegate z(circuit, qubit_index), to: Operators
  defdelegate h(circuit, qubit_index), to: Operators
  defdelegate cx(circuit, qubit_index1, qubit_index2), to: Operators
  defdelegate measure(circuit, qubit_index, classical_bit_index), to: Operators
  defdelegate draw(circuit), to: Draw, as: :circuit
end
