defmodule QED.Draw do
  @moduledoc """
  This module provides functions for drawing quantum circuits.

  The Draw module has been refactored to use a generic, extensible drawing system
  that supports easy addition of new quantum gates and operators through
  configuration-based rendering.
  """

  alias QED.QuantumCircuit
  alias QED.Draw.{GateConfig, LayoutConfig, Primitives, Drawable, GateDrawer}

  @doc """
  Draws a quantum circuit as an SVG image or PNG file.

  ## Parameters
  - `qc`: QuantumCircuit struct containing the circuit to draw
  - `format`: Output format, either `:svg` (default) or `:png`
  - `options`: Optional map of drawing options (layout overrides, etc.)

  ## Examples

      iex> circuit = QED.QuantumCircuit.new(2, 1)
      iex> circuit = QED.Operators.h(circuit, 0)
      iex> circuit = QED.Operators.cx(circuit, 0, 1)
      iex> svg = QED.Draw.circuit(circuit)
      iex> String.contains?(svg, "<svg")
      true

      iex> png_data = QED.Draw.circuit(circuit, :png)
      iex> is_binary(png_data)
      true

  ## Returns
  - For `:svg`: A string containing the complete SVG representation
  - For `:png`: Binary data of the PNG image
  """
  # Main circuit function with 1 parameter (defaults to SVG)
  def circuit(%QuantumCircuit{} = qc) do
    circuit(qc, :svg, %{})
  end

  # Circuit function with 2 parameters (format or options)
  def circuit(%QuantumCircuit{} = qc, format) when format in [:svg, :png] do
    circuit(qc, format, %{})
  end

  # Handle legacy call with options as second parameter (backward compatibility)
  def circuit(%QuantumCircuit{} = qc, options) when is_map(options) do
    circuit(qc, :svg, options)
  end

  # Circuit function with 3 parameters (format and options)
  def circuit(%QuantumCircuit{} = qc, format, options)
      when format in [:svg, :png] and is_map(options) do
    svg_content = generate_svg_content(qc, options)

    case format do
      :svg -> svg_content
      :png -> convert_svg_to_png(svg_content)
    end
  end

  @doc """
  Generates SVG content for a quantum circuit.

  ## Parameters
  - `qc`: QuantumCircuit struct containing the circuit to draw
  - `options`: Optional map of drawing options (layout overrides, etc.)

  ## Returns
  A string containing the complete SVG representation of the circuit.
  """

  def generate_svg_content(%QuantumCircuit{} = qc, options \\ %{}) do
    layout_config = LayoutConfig.get_config(Map.get(options, :layout, %{}))

    num_qubits = length(qc.qubits)
    num_instructions = length(qc.instructions)
    num_classical_bits = length(qc.classical_bits)

    {width, height} =
      LayoutConfig.calculate_dimensions(
        num_qubits,
        num_instructions,
        num_classical_bits,
        layout_config
      )

    layout_params = %{
      config: layout_config,
      num_qubits: num_qubits,
      num_classical_bits: num_classical_bits
    }

    svg_elements = [
      generate_svg_header(width, height),
      generate_qubit_labels(num_qubits, layout_config),
      generate_classical_bit_labels(num_classical_bits, num_qubits, layout_config),
      generate_qubit_lines(num_qubits, width, layout_config),
      generate_classical_lines(num_classical_bits, num_qubits, width, layout_config),
      generate_gate_drawings(qc.instructions, layout_params),
      generate_svg_footer()
    ]

    svg_elements
    |> List.flatten()
    |> Enum.join("\n")
  end

  @doc """
  Converts SVG content to PNG binary data.

  This function requires either `rsvg-convert` or ImageMagick to be installed on the system.

  ## Parameters
  - `svg_content`: String containing SVG markup
  - `options`: Optional conversion options (width, height, etc.)

  ## Returns
  Binary data of the PNG image.

  ## Raises
  - `RuntimeError` if no suitable SVG-to-PNG converter is found
  """
  @spec convert_svg_to_png(String.t(), map()) :: binary()
  def convert_svg_to_png(svg_content, options \\ %{}) do
    cond do
      has_rsvg_convert?() ->
        convert_with_rsvg(svg_content, options)

      has_imagemagick?() ->
        convert_with_imagemagick(svg_content, options)

      true ->
        raise RuntimeError, """
        PNG conversion requires either 'rsvg-convert' or ImageMagick to be installed.

        To install rsvg-convert:
        - Ubuntu/Debian: sudo apt-get install librsvg2-bin
        - macOS: brew install librsvg
        - CentOS/RHEL: sudo yum install librsvg2-tools

        To install ImageMagick:
        - Ubuntu/Debian: sudo apt-get install imagemagick
        - macOS: brew install imagemagick
        - CentOS/RHEL: sudo yum install ImageMagick
        """
    end
  end

  @doc """
  Draws a single instruction at a specific position.

  ## Parameters
  - `instruction`: The quantum circuit instruction to draw
  - `instruction_index`: Zero-based index of the instruction position
  - `layout_params`: Layout parameters containing configuration and circuit info

  ## Returns
  A list of SVG element strings representing the instruction.
  """
  @spec draw_instruction(tuple(), integer(), map()) :: [String.t()]
  def draw_instruction(instruction, instruction_index, layout_params) do
    layout_config = layout_params.config
    x = LayoutConfig.gate_x_position(instruction_index, layout_config)

    position = %{
      instruction_index: instruction_index,
      x: x,
      # Y position is determined by the specific gate drawing logic
      y: 0
    }

    # Use the custom drawer if specified, otherwise use the protocol
    gate_type = get_gate_type(instruction)
    config = GateConfig.get_config(gate_type)

    case config do
      %{custom_drawer: custom_drawer} when not is_nil(custom_drawer) ->
        apply_custom_drawer(custom_drawer, instruction, config, position, layout_params)

      _ ->
        Drawable.draw(instruction, position, layout_params)
    end
  end

  @doc """
  Gets information about a gate type.

  ## Parameters
  - `gate_type`: Atom representing the gate type

  ## Returns
  A map containing gate information or nil if not found.
  """
  @spec get_gate_info(atom()) :: map() | nil
  def get_gate_info(gate_type) when is_atom(gate_type) do
    GateConfig.get_config(gate_type)
  end

  @doc """
  Lists all supported gate types.

  ## Returns
  A list of atoms representing all registered gate types.
  """
  @spec list_supported_gates() :: [atom()]
  def list_supported_gates do
    GateConfig.get_gate_types()
  end

  @doc """
  Generates a plot of the probabilities from a simulation run.
  """
  def plot(results) when is_map(results) do
    total_shots = Enum.sum(Map.values(results))

    data =
      Enum.map(results, fn {state, count} ->
        %{state: state, probability: count / total_shots}
      end)

    VegaLite.new(width: 400, height: 300, title: "Simulation Results")
    |> VegaLite.data_from_values(data)
    |> VegaLite.mark(:bar)
    |> VegaLite.encode_field(:x, "state", type: :nominal, title: "State")
    |> VegaLite.encode_field(:y, "probability", type: :quantitative, title: "Probability")
  end

  # Private helper functions for SVG to PNG conversion

  defp has_rsvg_convert? do
    case System.cmd("which", ["rsvg-convert"], stderr_to_stdout: true) do
      {_, 0} -> true
      _ -> false
    end
  end

  defp has_imagemagick? do
    case System.cmd("which", ["convert"], stderr_to_stdout: true) do
      {_, 0} -> true
      _ -> false
    end
  end

  defp convert_with_rsvg(svg_content, options) do
    width = Map.get(options, :width, "")
    height = Map.get(options, :height, "")

    args = ["--format", "png"]
    args = if width != "", do: args ++ ["--width", to_string(width)], else: args
    args = if height != "", do: args ++ ["--height", to_string(height)], else: args
    args = args ++ ["/dev/stdin"]

    case System.cmd("rsvg-convert", args, input: svg_content) do
      {png_data, 0} -> png_data
      {error, _} -> raise RuntimeError, "rsvg-convert failed: #{error}"
    end
  end

  defp convert_with_imagemagick(svg_content, options) do
    width = Map.get(options, :width, "")
    height = Map.get(options, :height, "")

    resize_arg =
      case {width, height} do
        {"", ""} -> []
        {w, ""} -> ["-resize", "#{w}x"]
        {"", h} -> ["-resize", "x#{h}"]
        {w, h} -> ["-resize", "#{w}x#{h}"]
      end

    args = ["svg:/dev/stdin"] ++ resize_arg ++ ["png:/dev/stdout"]

    case System.cmd("convert", args, input: svg_content) do
      {png_data, 0} -> png_data
      {error, _} -> raise RuntimeError, "ImageMagick convert failed: #{error}"
    end
  end

  # Private helper functions for SVG generation

  defp generate_svg_header(width, height) do
    "<svg width=\"#{width}\" height=\"#{height}\" xmlns=\"http://www.w3.org/2000/svg\">"
  end

  defp generate_svg_footer do
    "</svg>"
  end

  defp generate_qubit_labels(num_qubits, layout_config) do
    label_x = LayoutConfig.label_x_position(layout_config)

    for i <- 0..(num_qubits - 1) do
      y = LayoutConfig.label_y_position(i, layout_config)

      Primitives.draw_text(label_x, y, "q#{i}:", %{
        font_size: layout_config.font_size,
        anchor: "end",
        color: "black"
      })
    end
  end

  defp generate_classical_bit_labels(num_classical_bits, num_qubits, layout_config) do
    label_x = LayoutConfig.label_x_position(layout_config)

    for i <- 0..(num_classical_bits - 1) do
      line_index = num_qubits + i
      y = LayoutConfig.label_y_position(line_index, layout_config)

      Primitives.draw_text(label_x, y, "c#{i}:", %{
        font_size: layout_config.font_size,
        anchor: "end",
        color: "black"
      })
    end
  end

  defp generate_qubit_lines(num_qubits, width, layout_config) do
    start_x = layout_config.h_padding
    end_x = width - layout_config.h_padding

    for i <- 0..(num_qubits - 1) do
      y = LayoutConfig.qubit_y_position(i, layout_config)
      Primitives.draw_line(start_x, y, end_x, y)
    end
  end

  defp generate_classical_lines(num_classical_bits, num_qubits, width, layout_config) do
    start_x = layout_config.h_padding
    end_x = width - layout_config.h_padding

    for i <- 0..(num_classical_bits - 1) do
      y = LayoutConfig.classical_y_position(i, num_qubits, layout_config)
      Primitives.draw_dashed_line(start_x, y, end_x, y)
    end
  end

  defp generate_gate_drawings(instructions, layout_params) do
    instructions
    |> Enum.with_index()
    |> Enum.map(fn {instruction, index} ->
      draw_instruction(instruction, index, layout_params)
    end)
  end

  defp get_gate_type(instruction) do
    case instruction do
      {gate_type, _} when gate_type in [:x, :y, :z, :h] -> gate_type
      {gate_type, _, _} when gate_type in [:cx, :measure] -> gate_type
      _ -> :unknown
    end
  end

  defp apply_custom_drawer(custom_drawer, instruction, config, position, layout_params) do
    case {custom_drawer, instruction} do
      {:draw_cnot, {:cx, control_qubit, target_qubit}} ->
        GateDrawer.draw_cnot(control_qubit, target_qubit, position, layout_params)

      {:draw_measurement, {:measure, qubit_index, classical_bit_index}} ->
        GateDrawer.draw_measurement(
          qubit_index,
          classical_bit_index,
          config,
          position,
          layout_params
        )

      _ ->
        # Fallback to protocol-based drawing
        Drawable.draw(instruction, position, layout_params)
    end
  end
end

defimpl Jason.Encoder, for: VegaLite do
  def encode(vl, opts) do
    vl
    |> VegaLite.to_spec()
    |> Jason.Encoder.encode(opts)
  end
end
