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
    instructions = circuit.instructions ++ [{:x, qubit_index}]
    %QuantumCircuit{circuit | instructions: instructions}
  end

  @doc """
  Applies the Y (Pauli-Y) gate to a qubit in the circuit.

  This function adds the `:y` instruction to the circuit's instruction list.
  """
  def y(%QuantumCircuit{} = circuit, qubit_index) do
    instructions = circuit.instructions ++ [{:y, qubit_index}]
    %QuantumCircuit{circuit | instructions: instructions}
  end

  @doc """
  Applies the Z (Pauli-Z) gate to a qubit in the circuit.

  This function adds the `:z` instruction to the circuit's instruction list.
  """
  def z(%QuantumCircuit{} = circuit, qubit_index) do
    instructions = circuit.instructions ++ [{:z, qubit_index}]
    %QuantumCircuit{circuit | instructions: instructions}
  end

  @doc """
  Applies the H (haddamard) gate to a qubit in the circuit.

  This function adds the `:h` instruction to the circuit's instruction list.
  """
  def h(%QuantumCircuit{} = circuit, qubit_index) do
    instructions = circuit.instructions ++ [{:h, qubit_index}]
    %QuantumCircuit{circuit | instructions: instructions}
  end

  @doc """
  Applies the CNOX (Contrilled-X) gate to a qubit in the circuit.

  This function adds the `:cx` instruction to the circuit's instruction list.
  """
  def cx(%QuantumCircuit{} = circuit, qubit_index1, qubit_index2) do
    instructions = circuit.instructions ++ [{:cx, qubit_index1, qubit_index2}]
    %QuantumCircuit{circuit | instructions: instructions}
  end

  @doc """
  Applies the 'Meeasure' operation to a qubit in the circuit.

  This function adds the `:measure` instruction to the circuit's instruction list.
  """
  def measure(%QuantumCircuit{} = circuit, qubit_index, classical_bit_index) do
    instructions = circuit.instructions ++ [{:measure, qubit_index, classical_bit_index}]
    %QuantumCircuit{circuit | instructions: instructions}
  end
end
