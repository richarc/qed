defmodule QED.Simulation do
  @moduledoc """
  This module simulates a quantum circuit.
  """

  alias QED.QuantumCircuit

  # Gate matrices
  @i Nx.tensor([[1, 0], [0, 1]])
  @x Nx.tensor([[0, 1], [1, 0]])
  @y Nx.tensor([[0, Complex.new(0, -1)], [Complex.new(0, 1), 0]])
  @z Nx.tensor([[1, 0], [0, -1]])
  @h Nx.divide(Nx.tensor([[1, 1], [1, -1]]), Nx.sqrt(Nx.tensor([2])))

  # Measurement projectors
  @p0 Nx.tensor([[1, 0], [0, 0]])
  @p1 Nx.tensor([[0, 0], [0, 1]])

  def run(%QuantumCircuit{} = circuit, shots) when is_integer(shots) and shots > 0 do
    num_qubits = length(circuit.qubits)
    operator = circuit_operator(circuit.instructions, num_qubits)
    final_state_vector = Nx.dot(operator, circuit.state_vector)
    probabilities = Nx.abs(final_state_vector) |> Nx.pow(2) |> Nx.to_list()
    num_states = round(:math.pow(2, num_qubits))
    labels = for i <- 0..(num_states - 1), do: i |> Integer.to_string(2) |> String.pad_leading(num_qubits, "0")

    1..shots
    |> Enum.map(fn _ ->
      random_outcome(labels, probabilities)
    end)
    |> Enum.frequencies()
  end

  defp circuit_operator(instructions, num_qubits) do
    initial_operator = Nx.eye(round(:math.pow(2, num_qubits)))

    Enum.reduce(instructions, initial_operator, fn instruction, acc ->
      op = get_operator(instruction, num_qubits)
      Nx.dot(op, acc)
    end)
  end

  defp get_operator({:x, target}, num_qubits), do: gate_operator_multi(%{target => @x}, num_qubits)
  defp get_operator({:y, target}, num_qubits), do: gate_operator_multi(%{target => @y}, num_qubits)
  defp get_operator({:z, target}, num_qubits), do: gate_operator_multi(%{target => @z}, num_qubits)
  defp get_operator({:h, target}, num_qubits), do: gate_operator_multi(%{target => @h}, num_qubits)
  defp get_operator({:cx, control, target}, num_qubits) do
    op1 = gate_operator_multi(%{control => @p0}, num_qubits)
    op2 = gate_operator_multi(%{control => @p1, target => @x}, num_qubits)
    Nx.add(op1, op2)
  end
  defp get_operator({:measure, _, _}, num_qubits) do
    # For simulation purposes, measurement doesn't change the state vector
    # The measurement outcomes are calculated from the final state vector
    Nx.eye(round(:math.pow(2, num_qubits)))
  end

  defp gate_operator_multi(gates, num_qubits) do
    Enum.reduce((num_qubits - 1)..0//-1, Nx.tensor([[1]]), fn i, acc ->
      op = Map.get(gates, i, @i)
      QED.Qmath.kronecker_product(acc, op)
    end)
  end

  defp random_outcome(labels, probabilities) do
    random = :rand.uniform()
    {outcome, _} =
      Enum.zip(labels, probabilities)
      |> Enum.reduce_while({nil, 0}, fn {label, prob}, {_, acc_prob} ->
        new_acc_prob = acc_prob + prob
        if random <= new_acc_prob do
          {:halt, {label, new_acc_prob}}
        else
          {:cont, {nil, new_acc_prob}}
        end
      end)
    outcome
  end
end
