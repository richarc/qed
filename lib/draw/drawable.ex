defprotocol QED.Draw.Drawable do
  @moduledoc """
  Protocol for drawing quantum circuit instructions.

  This protocol provides a standard interface for rendering different types of
  quantum circuit instructions as SVG elements. It enables extensibility by
  allowing new instruction types to implement their own drawing logic.
  """

  @type position :: %{
          instruction_index: integer(),
          x: number(),
          y: number()
        }

  @type layout_params :: %{
          config: QED.Draw.LayoutConfig.layout_config(),
          num_qubits: integer(),
          num_classical_bits: integer()
        }

  @doc """
  Draws an instruction as SVG elements.

  ## Parameters
  - `instruction`: The quantum circuit instruction to draw
  - `position`: Position information for the instruction
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings that represent the instruction.
  """
  @spec draw(any(), position(), layout_params()) :: [String.t()]
  def draw(instruction, position, layout_params)

  @doc """
  Gets the bounding box for an instruction.

  ## Parameters
  - `instruction`: The quantum circuit instruction
  - `position`: Position information for the instruction
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A map with `:width` and `:height` keys representing the bounding box.
  """
  @spec bounding_box(any(), position(), layout_params()) :: %{width: number(), height: number()}
  def bounding_box(instruction, position, layout_params)

  @doc """
  Determines if an instruction affects multiple qubits.

  ## Parameters
  - `instruction`: The quantum circuit instruction

  ## Returns
  Boolean indicating if the instruction spans multiple qubits.
  """
  @spec multi_qubit?(any()) :: boolean()
  def multi_qubit?(instruction)
end

defimpl QED.Draw.Drawable, for: Tuple do
  @moduledoc """
  Implementation of the Drawable protocol for tuple-based instructions.

  This handles the standard instruction format used in the quantum circuit,
  where instructions are represented as tuples like `{:x, qubit_index}`.
  """

  alias QED.Draw.{GateConfig, Primitives, LayoutConfig}

  def draw(instruction, position, layout_params) do
    gate_type = get_gate_type(instruction)
    config = GateConfig.get_config(gate_type)

    case config do
      nil ->
        draw_unknown_gate(instruction, position, layout_params)

      %{type: :single_qubit} ->
        draw_single_qubit_gate(instruction, config, position, layout_params)

      %{type: :two_qubit} ->
        draw_two_qubit_gate(instruction, config, position, layout_params)

      %{type: :measurement} ->
        draw_measurement_gate(instruction, config, position, layout_params)
    end
  end

  def bounding_box(instruction, _position, layout_params) do
    gate_type = get_gate_type(instruction)
    config = GateConfig.get_config(gate_type)
    layout_config = layout_params.config

    case config do
      %{type: :single_qubit} ->
        %{width: layout_config.gate_width, height: layout_config.gate_height}

      %{type: :two_qubit} ->
        # Two-qubit gates may span multiple qubit lines
        {_, control_qubit, target_qubit} = instruction
        min_qubit = min(control_qubit, target_qubit)
        max_qubit = max(control_qubit, target_qubit)
        height = (max_qubit - min_qubit + 1) * layout_config.qubit_spacing
        %{width: layout_config.gate_width, height: height}

      %{type: :measurement} ->
        # Measurements span from qubit line to classical line
        {_, qubit_index, classical_bit_index} = instruction

        classical_y =
          LayoutConfig.classical_y_position(
            classical_bit_index,
            layout_params.num_qubits,
            layout_config
          )

        qubit_y = LayoutConfig.qubit_y_position(qubit_index, layout_config)
        height = abs(classical_y - qubit_y) + layout_config.gate_height
        %{width: layout_config.gate_width, height: height}

      _ ->
        %{width: layout_config.gate_width, height: layout_config.gate_height}
    end
  end

  def multi_qubit?(instruction) do
    gate_type = get_gate_type(instruction)
    config = GateConfig.get_config(gate_type)

    case config do
      %{type: type} when type in [:two_qubit, :measurement] -> true
      _ -> false
    end
  end

  # Private helper functions

  defp get_gate_type(instruction) do
    case instruction do
      {gate_type, _} when gate_type in [:x, :y, :z, :h] -> gate_type
      {gate_type, _, _} when gate_type in [:cx, :measure] -> gate_type
      _ -> :unknown
    end
  end

  defp draw_single_qubit_gate(
         {_, qubit_index},
         %{label: label, color: color},
         position,
         layout_params
       ) do
    layout_config = layout_params.config
    y = LayoutConfig.gate_y_position(qubit_index, layout_config)

    Primitives.draw_rect_gate(
      position.x,
      y,
      layout_config.gate_width,
      layout_config.gate_height,
      label,
      color
    )
  end

  defp draw_two_qubit_gate(
         {:cx, control_qubit, target_qubit},
         _config,
         position,
         layout_params
       ) do
    layout_config = layout_params.config
    y_control = LayoutConfig.qubit_y_position(control_qubit, layout_config)
    y_target = LayoutConfig.qubit_y_position(target_qubit, layout_config)
    center_x = position.x + layout_config.gate_width / 2

    [
      Primitives.draw_control_dot(center_x, y_control),
      Primitives.draw_line(center_x, y_control, center_x, y_target),
      Primitives.draw_target_circle(center_x, y_target)
    ]
  end

  defp draw_measurement_gate(
         {:measure, qubit_index, classical_bit_index},
         %{label: label, color: color},
         position,
         layout_params
       ) do
    layout_config = layout_params.config
    y_qubit = LayoutConfig.gate_y_position(qubit_index, layout_config)

    y_classical =
      LayoutConfig.classical_y_position(
        classical_bit_index,
        layout_params.num_qubits,
        layout_config
      )

    gate_elements =
      Primitives.draw_rect_gate(
        position.x,
        y_qubit,
        layout_config.gate_width,
        layout_config.gate_height,
        label,
        color
      )

    # Add measurement symbol inside the gate
    center_x = position.x + layout_config.gate_width / 2
    center_y = y_qubit + layout_config.gate_height / 2
    measurement_symbol = Primitives.draw_measurement_symbol(center_x, center_y, 12)

    # Add connection line to classical bit
    connection_line =
      Primitives.draw_line(
        center_x,
        y_qubit + layout_config.gate_height,
        center_x,
        y_classical
      )

    gate_elements ++ measurement_symbol ++ [connection_line]
  end

  defp draw_unknown_gate(instruction, position, layout_params) do
    layout_config = layout_params.config
    # Try to extract qubit index from instruction
    qubit_index =
      case instruction do
        {_, qubit_index} when is_integer(qubit_index) -> qubit_index
        {_, qubit_index, _} when is_integer(qubit_index) -> qubit_index
        _ -> 0
      end

    y = LayoutConfig.gate_y_position(qubit_index, layout_config)

    Primitives.draw_rect_gate(
      position.x,
      y,
      layout_config.gate_width,
      layout_config.gate_height,
      "?",
      "#CCCCCC"
    )
  end
end
