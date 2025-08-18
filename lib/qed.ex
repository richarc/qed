defmodule QED do
  @moduledoc """
  Quantum computing simulator in Elixir.

  This module provides a high-level interface for creating and manipulating
  quantum circuits, applying quantum operators, and visualizing results.

  ## Drawing Circuits

  The `draw/1`, `draw/2`, and `draw/3` functions support multiple output formats:

  - `:svg` (default) - Returns SVG markup as a string
  - `:png` - Returns PNG binary data (requires rsvg-convert or ImageMagick)

  ### Examples

      # Create and draw a simple circuit
      circuit = QED.new_circuit(2, 1)
      circuit = circuit |> QED.h(0) |> QED.cx(0, 1)

      # Generate SVG (default)
      svg = QED.draw(circuit)

      # Generate PNG
      png_data = QED.draw(circuit, :png)

      # With custom options
      svg = QED.draw(circuit, :svg, %{layout: %{qubit_spacing: 60}})

  ### PNG Requirements

  PNG generation requires one of the following tools to be installed:

  - `rsvg-convert` (recommended):
    - Ubuntu/Debian: `sudo apt-get install librsvg2-bin`
    - macOS: `brew install librsvg`
    - CentOS/RHEL: `sudo yum install librsvg2-tools`

  - ImageMagick:
    - Ubuntu/Debian: `sudo apt-get install imagemagick`
    - macOS: `brew install imagemagick`
    - CentOS/RHEL: `sudo yum install ImageMagick`
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
  defdelegate draw(circuit, format), to: Draw, as: :circuit
  defdelegate draw(circuit, format, options), to: Draw, as: :circuit
  defdelegate run(circuit, shots), to: QED.Simulation
  defdelegate plot(results), to: QED.Draw
end
