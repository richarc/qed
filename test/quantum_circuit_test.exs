defmodule QED.QuantumCircuitTest do
  use ExUnit.Case
  doctest QED.QuantumCircuit

  alias QED.QuantumCircuit
  alias QED.Qubit

  test "new/2 creates a circuit with the correct number of qubits and classical bits" do
    circuit = QuantumCircuit.new(2, 3)
    assert length(circuit.qubits) == 2
    assert length(circuit.classical_bits) == 3
  end

  test "new/2 create a circuit with defulat values new()" do
    circuit = QuantumCircuit.new()
    assert length(circuit.qubits) == 1
    assert length(circuit.classical_bits) == 1
  end

  test "new/2 calculates the correct initial state vector for a single qubit" do
    circuit = QuantumCircuit.new(1, 1)
    expected_state_vector = Qubit.new().state
    assert circuit.state_vector == expected_state_vector
  end

  test "new/2 calculates the correct initial state vector for multiple qubits" do
    circuit = QuantumCircuit.new(2, 1)
    ket0 = Qubit.new()
    expected_state_vector = Nx.outer(ket0.state, ket0.state)
    assert circuit.state_vector == expected_state_vector
  end
end
