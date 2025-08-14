defmodule QED.Operators do
  @moduledoc """
  A collection of quantum operators that can be applied to a quantum circuit.
  """

  alias QED.QuantumCircuit

  @doc """
  Applies the X (Pauli-X) gate to a qubit in the circuit.

  This function adds the `:x` instruction to the circuit's instruction list.
  """
  def x(%QuantumCircuit{} = circuit, qubit_index) do
    instructions = [{:x, qubit_index} | circuit.instructions]
    %QuantumCircuit{circuit | instructions: instructions}
  end
end
