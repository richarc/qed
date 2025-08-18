defmodule QED.Draw.GateDrawer do
  @moduledoc """
  Custom drawing functions for specific quantum gates.

  This module contains specialized drawing functions for gates that require
  custom rendering beyond the standard rectangular gate appearance.
  """

  alias QED.Draw.{Primitives, LayoutConfig}

  @doc """
  Draws a CNOT (Controlled-X) gate.

  ## Parameters
  - `control_qubit`: Index of the control qubit
  - `target_qubit`: Index of the target qubit
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the CNOT gate.
  """
  @spec draw_cnot(integer(), integer(), map(), map()) :: [String.t()]
  def draw_cnot(control_qubit, target_qubit, position, layout_params) do
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

  @doc """
  Draws a measurement gate with measurement symbol.

  ## Parameters
  - `qubit_index`: Index of the qubit being measured
  - `classical_bit_index`: Index of the classical bit storing the result
  - `config`: Gate configuration
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the measurement gate.
  """
  @spec draw_measurement(integer(), integer(), map(), map(), map()) :: [String.t()]
  def draw_measurement(qubit_index, classical_bit_index, config, position, layout_params) do
    layout_config = layout_params.config
    y_qubit = LayoutConfig.gate_y_position(qubit_index, layout_config)

    y_classical =
      LayoutConfig.classical_y_position(
        classical_bit_index,
        layout_params.num_qubits,
        layout_config
      )

    # Draw the measurement box
    gate_elements =
      Primitives.draw_rect_gate(
        position.x,
        y_qubit,
        layout_config.gate_width,
        layout_config.gate_height,
        config.label,
        config.color
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

  @doc """
  Draws a controlled-Z gate.

  ## Parameters
  - `control_qubit`: Index of the control qubit
  - `target_qubit`: Index of the target qubit
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the CZ gate.
  """
  @spec draw_cz(integer(), integer(), map(), map()) :: [String.t()]
  def draw_cz(control_qubit, target_qubit, position, layout_params) do
    layout_config = layout_params.config
    y_control = LayoutConfig.qubit_y_position(control_qubit, layout_config)
    y_target = LayoutConfig.qubit_y_position(target_qubit, layout_config)
    center_x = position.x + layout_config.gate_width / 2

    [
      Primitives.draw_control_dot(center_x, y_control),
      Primitives.draw_line(center_x, y_control, center_x, y_target),
      Primitives.draw_control_dot(center_x, y_target)
    ]
  end

  @doc """
  Draws a swap gate (X symbols connected by lines).

  ## Parameters
  - `qubit1`: Index of the first qubit
  - `qubit2`: Index of the second qubit
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the SWAP gate.
  """
  @spec draw_swap(integer(), integer(), map(), map()) :: [String.t()]
  def draw_swap(qubit1, qubit2, position, layout_params) do
    layout_config = layout_params.config
    y1 = LayoutConfig.qubit_y_position(qubit1, layout_config)
    y2 = LayoutConfig.qubit_y_position(qubit2, layout_config)
    center_x = position.x + layout_config.gate_width / 2

    # Draw X symbols on both qubits
    x_size = 8

    [
      # Connection line
      Primitives.draw_line(center_x, y1, center_x, y2),
      # X on first qubit
      Primitives.draw_line(center_x - x_size, y1 - x_size, center_x + x_size, y1 + x_size),
      Primitives.draw_line(center_x - x_size, y1 + x_size, center_x + x_size, y1 - x_size),
      # X on second qubit
      Primitives.draw_line(center_x - x_size, y2 - x_size, center_x + x_size, y2 + x_size),
      Primitives.draw_line(center_x - x_size, y2 + x_size, center_x + x_size, y2 - x_size)
    ]
  end

  @doc """
  Draws a Toffoli (CCX) gate with two control qubits and one target.

  ## Parameters
  - `control1`: Index of the first control qubit
  - `control2`: Index of the second control qubit
  - `target`: Index of the target qubit
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the Toffoli gate.
  """
  @spec draw_toffoli(integer(), integer(), integer(), map(), map()) :: [String.t()]
  def draw_toffoli(control1, control2, target, position, layout_params) do
    layout_config = layout_params.config
    y_control1 = LayoutConfig.qubit_y_position(control1, layout_config)
    y_control2 = LayoutConfig.qubit_y_position(control2, layout_config)
    y_target = LayoutConfig.qubit_y_position(target, layout_config)
    center_x = position.x + layout_config.gate_width / 2

    min_y = min(y_control1, min(y_control2, y_target))
    max_y = max(y_control1, max(y_control2, y_target))

    [
      # Vertical line connecting all qubits
      Primitives.draw_line(center_x, min_y, center_x, max_y),
      # Control dots
      Primitives.draw_control_dot(center_x, y_control1),
      Primitives.draw_control_dot(center_x, y_control2),
      # Target circle
      Primitives.draw_target_circle(center_x, y_target)
    ]
  end

  @doc """
  Draws a rotation gate (RX, RY, RZ) with parameter display.

  ## Parameters
  - `gate_type`: Type of rotation gate (:rx, :ry, :rz)
  - `qubit_index`: Index of the target qubit
  - `angle`: Rotation angle (in radians or as a parameter string)
  - `config`: Gate configuration
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the rotation gate.
  """
  @spec draw_rotation(atom(), integer(), any(), map(), map(), map()) :: [String.t()]
  def draw_rotation(gate_type, qubit_index, angle, config, position, layout_params) do
    layout_config = layout_params.config
    y = LayoutConfig.gate_y_position(qubit_index, layout_config)

    # Format the gate label with parameter
    label =
      case gate_type do
        :rx -> "RX"
        :ry -> "RY"
        :rz -> "RZ"
        _ -> "R"
      end

    # Draw the main gate rectangle
    gate_elements =
      Primitives.draw_rect_gate(
        position.x,
        y,
        layout_config.gate_width,
        layout_config.gate_height,
        label,
        config.color
      )

    # Add parameter text below the gate
    param_text =
      case angle do
        angle when is_number(angle) ->
          formatted_angle = :erlang.float_to_binary(angle, decimals: 3)
          "(#{formatted_angle})"

        angle when is_binary(angle) ->
          "(#{angle})"

        _ ->
          "(θ)"
      end

    param_x = position.x + layout_config.gate_width / 2
    param_y = y + layout_config.gate_height + 12

    parameter_label =
      Primitives.draw_text(param_x, param_y, param_text, %{
        font_size: 10,
        anchor: "middle",
        color: "black"
      })

    gate_elements ++ [parameter_label]
  end

  @doc """
  Draws a phase gate with parameter display.

  ## Parameters
  - `qubit_index`: Index of the target qubit
  - `phase`: Phase angle (in radians or as a parameter string)
  - `config`: Gate configuration
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the phase gate.
  """
  @spec draw_phase(integer(), any(), map(), map(), map()) :: [String.t()]
  def draw_phase(qubit_index, phase, config, position, layout_params) do
    layout_config = layout_params.config
    y = LayoutConfig.gate_y_position(qubit_index, layout_config)

    # Draw the main gate rectangle
    gate_elements =
      Primitives.draw_rect_gate(
        position.x,
        y,
        layout_config.gate_width,
        layout_config.gate_height,
        "P",
        config.color
      )

    # Add parameter text below the gate
    param_text =
      case phase do
        phase when is_number(phase) ->
          formatted_phase = :erlang.float_to_binary(phase, decimals: 3)
          "(#{formatted_phase})"

        phase when is_binary(phase) ->
          "(#{phase})"

        _ ->
          "(φ)"
      end

    param_x = position.x + layout_config.gate_width / 2
    param_y = y + layout_config.gate_height + 12

    parameter_label =
      Primitives.draw_text(param_x, param_y, param_text, %{
        font_size: 10,
        anchor: "middle",
        color: "black"
      })

    gate_elements ++ [parameter_label]
  end

  @doc """
  Draws a custom gate with arbitrary label and styling.

  ## Parameters
  - `qubit_indices`: List of qubit indices this gate affects
  - `label`: Gate label to display
  - `color`: Gate color
  - `position`: Position information for the gate
  - `layout_params`: Layout parameters and configuration

  ## Returns
  A list of SVG element strings representing the custom gate.
  """
  @spec draw_custom(list(integer()), String.t(), String.t(), map(), map()) :: [String.t()]
  def draw_custom(qubit_indices, label, color, position, layout_params) do
    layout_config = layout_params.config

    case length(qubit_indices) do
      1 ->
        # Single qubit gate
        [qubit_index] = qubit_indices
        y = LayoutConfig.gate_y_position(qubit_index, layout_config)

        Primitives.draw_rect_gate(
          position.x,
          y,
          layout_config.gate_width,
          layout_config.gate_height,
          label,
          color
        )

      _ ->
        # Multi-qubit gate - draw a larger rectangle spanning all qubits
        min_qubit = Enum.min(qubit_indices)
        max_qubit = Enum.max(qubit_indices)

        y_start = LayoutConfig.gate_y_position(min_qubit, layout_config)
        y_end = LayoutConfig.gate_y_position(max_qubit, layout_config)
        height = y_end - y_start + layout_config.gate_height

        Primitives.draw_rect_gate(
          position.x,
          y_start,
          layout_config.gate_width,
          height,
          label,
          color
        )
    end
  end
end
