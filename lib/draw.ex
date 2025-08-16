defmodule QED.Draw do
  @moduledoc """
  This module provides functions for drawing quantum circuits.
  """

  alias QED.QuantumCircuit

  @doc """
  Draws a quantum circuit as an SVG image.
  """
  def circuit(%QuantumCircuit{} = qc) do
    # Constants for SVG layout
    qubit_spacing = 50
    gate_width = 40
    gate_height = 40
    h_padding = 60
    v_padding = 20

    num_qubits = length(qc.qubits)
    num_instructions = length(qc.instructions)
    num_classical_bits = length(qc.classical_bits)

    width = num_instructions * (gate_width + 10) + 2 * h_padding
    height = (num_qubits + num_classical_bits) * qubit_spacing + 2 * v_padding

    svg_header = "<svg width=\"#{width}\" height=\"#{height}\" xmlns=\"http://www.w3.org/2000/svg\">\n"
    svg_end = "</svg>"

    qubit_labels =
      for i <- 0..(num_qubits - 1) do
        y = v_padding + i * qubit_spacing + gate_height / 2 + 4
        "<text x=\"#{h_padding - 10}\" y=\"#{y}\" text-anchor=\"end\" font-size=\"16\">q#{i}:</text>"
      end

    classical_bit_labels =
      for i <- 0..(num_classical_bits - 1) do
        y = v_padding + (num_qubits + i) * qubit_spacing + gate_height / 2 + 4
        "<text x=\"#{h_padding - 10}\" y=\"#{y}\" text-anchor=\"end\" font-size=\"16\">c#{i}:</text>"
      end

    qubit_lines =
      for i <- 0..(num_qubits - 1) do
        y = v_padding + i * qubit_spacing + gate_height / 2
        "<line x1=\"#{h_padding}\" y1=\"#{y}\" x2=\"#{width - h_padding}\" y2=\"#{y}\" stroke=\"black\" />"
      end

    classical_lines =
      for i <- 0..(num_classical_bits - 1) do
        y = v_padding + (num_qubits + i) * qubit_spacing + gate_height / 2
        "<line x1=\"#{h_padding}\" y1=\"#{y}\" x2=\"#{width - h_padding}\" y2=\"#{y}\" stroke=\"black\" stroke-dasharray=\"5,5\" />"
      end

    gate_drawings =
      Enum.with_index(qc.instructions)
      |> Enum.map(fn {instruction, i} ->
        draw_gate(instruction, i, num_qubits, qubit_spacing, gate_width, gate_height, h_padding, v_padding)
      end)

    [svg_header, qubit_labels, classical_bit_labels, qubit_lines, classical_lines, gate_drawings, svg_end]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp draw_gate({:x, qubit_index}, i, _num_qubits, qubit_spacing, gate_width, gate_height, h_padding, v_padding) do
    x = h_padding + i * (gate_width + 10)
    y = v_padding + qubit_index * qubit_spacing

    [
      "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{gate_width}\" height=\"#{gate_height}\" fill=\"#FF69B4\" stroke=\"black\" />",
      "<text x=\"#{x + gate_width / 2}\" y=\"#{y + gate_height / 2 + 4}\" text-anchor=\"middle\" font-size=\"20\">X</text>"
    ]
  end

  defp draw_gate({:y, qubit_index}, i, _num_qubits, qubit_spacing, gate_width, gate_height, h_padding, v_padding) do
    x = h_padding + i * (gate_width + 10)
    y = v_padding + qubit_index * qubit_spacing

    [
      "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{gate_width}\" height=\"#{gate_height}\" fill=\"#FFD700\" stroke=\"black\" />",
      "<text x=\"#{x + gate_width / 2}\" y=\"#{y + gate_height / 2 + 4}\" text-anchor=\"middle\" font-size=\"20\">Y</text>"
    ]
  end

  defp draw_gate({:z, qubit_index}, i, _num_qubits, qubit_spacing, gate_width, gate_height, h_padding, v_padding) do
    x = h_padding + i * (gate_width + 10)
    y = v_padding + qubit_index * qubit_spacing

    [
      "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{gate_width}\" height=\"#{gate_height}\" fill=\"#00FFFF\" stroke=\"black\" />",
      "<text x=\"#{x + gate_width / 2}\" y=\"#{y + gate_height / 2 + 4}\" text-anchor=\"middle\" font-size=\"20\">Z</text>"
    ]
  end

  defp draw_gate({:h, qubit_index}, i, _num_qubits, qubit_spacing, gate_width, gate_height, h_padding, v_padding) do
    x = h_padding + i * (gate_width + 10)
    y = v_padding + qubit_index * qubit_spacing

    [
      "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{gate_width}\" height=\"#{gate_height}\" fill=\"#ADFF2F\" stroke=\"black\" />",
      "<text x=\"#{x + gate_width / 2}\" y=\"#{y + gate_height / 2 + 4}\" text-anchor=\"middle\" font-size=\"20\">H</text>"
    ]
  end

  defp draw_gate({:cx, control_qubit, target_qubit}, i, _num_qubits, qubit_spacing, gate_width, gate_height, h_padding, v_padding) do
    x = h_padding + i * (gate_width + 10)
    y_control = v_padding + control_qubit * qubit_spacing
    y_target = v_padding + target_qubit * qubit_spacing

    [
      "<circle cx=\"#{x + gate_width / 2}\" cy=\"#{y_control + gate_height / 2}\" r=\"5\" fill=\"black\" />",
      "<line x1=\"#{x + gate_width / 2}\" y1=\"#{y_control + gate_height / 2}\" x2=\"#{x + gate_width / 2}\" y2=\"#{y_target + gate_height / 2}\" stroke=\"black\" />",
      "<circle cx=\"#{x + gate_width / 2}\" cy=\"#{y_target + gate_height / 2}\" r=\"15\" fill=\"none\" stroke=\"black\" />",
      "<line x1=\"#{x + gate_width / 2 - 10}\" y1=\"#{y_target + gate_height / 2}\" x2=\"#{x + gate_width / 2 + 10}\" y2=\"#{y_target + gate_height / 2}\" stroke=\"black\" />",
      "<line x1=\"#{x + gate_width / 2}\" y1=\"#{y_target + gate_height / 2 - 10}\" x2=\"#{x + gate_width / 2}\" y2=\"#{y_target + gate_height / 2 + 10}\" stroke=\"black\" />"
    ]
  end

  defp draw_gate({:measure, qubit_index, classical_bit_index}, i, num_qubits, qubit_spacing, gate_width, gate_height, h_padding, v_padding) do
    x = h_padding + i * (gate_width + 10)
    y_qubit = v_padding + qubit_index * qubit_spacing
    y_classical = v_padding + (num_qubits + classical_bit_index) * qubit_spacing

    [
      "<rect x=\"#{x}\" y=\"#{y_qubit}\" width=\"#{gate_width}\" height=\"#{gate_height}\" fill=\"#FFA500\" stroke=\"black\" />",
      "<text x=\"#{x + gate_width / 2}\" y=\"#{y_qubit + gate_height / 2 + 4}\" text-anchor=\"middle\" font-size=\"20\">M</text>",
      "<line x1=\"#{x + gate_width / 2}\" y1=\"#{y_qubit + gate_height}\" x2=\"#{x + gate_width / 2}\" y2=\"#{y_classical + gate_height / 2}\" stroke=\"black\" />"
    ]
  end
end
