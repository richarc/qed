defmodule QED.Draw.LayoutConfig do
  @moduledoc """
  Configuration for circuit layout parameters.

  This module provides centralized configuration for the visual layout of
  quantum circuit diagrams, including spacing, dimensions, and positioning.
  """

  @type layout_config :: %{
          qubit_spacing: number(),
          gate_width: number(),
          gate_height: number(),
          h_padding: number(),
          v_padding: number(),
          gate_spacing: number(),
          font_size: number(),
          label_offset: number(),
          line_width: number()
        }

  @default_config %{
    qubit_spacing: 50,
    gate_width: 40,
    gate_height: 40,
    h_padding: 60,
    v_padding: 20,
    gate_spacing: 10,
    font_size: 16,
    label_offset: 10,
    line_width: 1
  }

  @doc """
  Gets the default layout configuration.

  ## Examples

      iex> config = QED.Draw.LayoutConfig.default_config()
      iex> config.qubit_spacing
      50
  """
  @spec default_config() :: layout_config()
  def default_config, do: @default_config

  @doc """
  Gets a layout configuration with optional overrides.

  ## Parameters
  - `overrides`: Map of configuration values to override

  ## Examples

      iex> config = QED.Draw.LayoutConfig.get_config(%{qubit_spacing: 60})
      iex> config.qubit_spacing
      60
      iex> config.gate_width
      40
  """
  @spec get_config(map()) :: layout_config()
  def get_config(overrides \\ %{}) do
    Map.merge(@default_config, overrides)
  end

  @doc """
  Calculates the total dimensions needed for a circuit diagram.

  ## Parameters
  - `num_qubits`: Number of qubits in the circuit
  - `num_instructions`: Number of instructions (gates) in the circuit
  - `num_classical_bits`: Number of classical bits in the circuit
  - `config`: Layout configuration (optional, uses default if not provided)

  ## Returns
  A tuple `{width, height}` representing the required SVG dimensions.

  ## Examples

      iex> QED.Draw.LayoutConfig.calculate_dimensions(3, 5, 2)
      {310, 270}
  """
  @spec calculate_dimensions(integer(), integer(), integer(), layout_config()) ::
          {number(), number()}
  def calculate_dimensions(
        num_qubits,
        num_instructions,
        num_classical_bits,
        config \\ @default_config
      ) do
    width = num_instructions * (config.gate_width + config.gate_spacing) + 2 * config.h_padding
    total_lines = num_qubits + num_classical_bits
    height = total_lines * config.qubit_spacing + 2 * config.v_padding

    {width, height}
  end

  @doc """
  Calculates the X position for a gate at a given instruction index.

  ## Parameters
  - `instruction_index`: Zero-based index of the instruction
  - `config`: Layout configuration (optional, uses default if not provided)

  ## Examples

      iex> QED.Draw.LayoutConfig.gate_x_position(0)
      60

      iex> QED.Draw.LayoutConfig.gate_x_position(1)
      110
  """
  @spec gate_x_position(integer(), layout_config()) :: number()
  def gate_x_position(instruction_index, config \\ @default_config) do
    config.h_padding + instruction_index * (config.gate_width + config.gate_spacing)
  end

  @doc """
  Calculates the Y position for a qubit line.

  ## Parameters
  - `qubit_index`: Zero-based index of the qubit
  - `config`: Layout configuration (optional, uses default if not provided)

  ## Examples

      iex> QED.Draw.LayoutConfig.qubit_y_position(0)
      40

      iex> QED.Draw.LayoutConfig.qubit_y_position(1)
      90
  """
  @spec qubit_y_position(integer(), layout_config()) :: number()
  def qubit_y_position(qubit_index, config \\ @default_config) do
    config.v_padding + qubit_index * config.qubit_spacing + config.gate_height / 2
  end

  @doc """
  Calculates the Y position for a classical bit line.

  ## Parameters
  - `classical_bit_index`: Zero-based index of the classical bit
  - `num_qubits`: Total number of qubits (classical lines come after qubit lines)
  - `config`: Layout configuration (optional, uses default if not provided)

  ## Examples

      iex> QED.Draw.LayoutConfig.classical_y_position(0, 3)
      190
  """
  @spec classical_y_position(integer(), integer(), layout_config()) :: number()
  def classical_y_position(classical_bit_index, num_qubits, config \\ @default_config) do
    config.v_padding + (num_qubits + classical_bit_index) * config.qubit_spacing +
      config.gate_height / 2
  end

  @doc """
  Calculates the Y position for gate drawing (top-left corner).

  ## Parameters
  - `qubit_index`: Zero-based index of the target qubit
  - `config`: Layout configuration (optional, uses default if not provided)

  ## Examples

      iex> QED.Draw.LayoutConfig.gate_y_position(0)
      20

      iex> QED.Draw.LayoutConfig.gate_y_position(1)
      70
  """
  @spec gate_y_position(integer(), layout_config()) :: number()
  def gate_y_position(qubit_index, config \\ @default_config) do
    config.v_padding + qubit_index * config.qubit_spacing
  end

  @doc """
  Calculates the X position for qubit labels.

  ## Parameters
  - `config`: Layout configuration (optional, uses default if not provided)

  ## Examples

      iex> QED.Draw.LayoutConfig.label_x_position()
      50
  """
  @spec label_x_position(layout_config()) :: number()
  def label_x_position(config \\ @default_config) do
    config.h_padding - config.label_offset
  end

  @doc """
  Calculates the Y position for labels (both qubit and classical bit labels).

  ## Parameters
  - `line_index`: Zero-based index of the line (qubit or classical bit)
  - `config`: Layout configuration (optional, uses default if not provided)

  ## Examples

      iex> QED.Draw.LayoutConfig.label_y_position(0)
      44
  """
  @spec label_y_position(integer(), layout_config()) :: number()
  def label_y_position(line_index, config \\ @default_config) do
    config.v_padding + line_index * config.qubit_spacing + config.gate_height / 2 + 4
  end

  @doc """
  Validates a layout configuration.

  ## Parameters
  - `config`: Configuration map to validate

  ## Examples

      iex> QED.Draw.LayoutConfig.valid_config?(%{qubit_spacing: 50, gate_width: 40})
      false

      iex> valid_config = QED.Draw.LayoutConfig.default_config()
      iex> QED.Draw.LayoutConfig.valid_config?(valid_config)
      true
  """
  @spec valid_config?(map()) :: boolean()
  def valid_config?(config) when is_map(config) do
    required_keys = [
      :qubit_spacing,
      :gate_width,
      :gate_height,
      :h_padding,
      :v_padding,
      :gate_spacing,
      :font_size,
      :label_offset,
      :line_width
    ]

    Enum.all?(required_keys, &Map.has_key?(config, &1)) and
      Enum.all?(required_keys, fn key ->
        value = Map.get(config, key)
        is_number(value) and value > 0
      end)
  end

  def valid_config?(_), do: false

  @doc """
  Creates a compact layout configuration (smaller spacing and dimensions).

  ## Examples

      iex> config = QED.Draw.LayoutConfig.compact_config()
      iex> config.qubit_spacing
      35
  """
  @spec compact_config() :: layout_config()
  def compact_config do
    %{
      @default_config
      | qubit_spacing: 35,
        gate_width: 30,
        gate_height: 30,
        h_padding: 40,
        v_padding: 15,
        gate_spacing: 8,
        font_size: 14
    }
  end

  @doc """
  Creates a spacious layout configuration (larger spacing and dimensions).

  ## Examples

      iex> config = QED.Draw.LayoutConfig.spacious_config()
      iex> config.qubit_spacing
      70
  """
  @spec spacious_config() :: layout_config()
  def spacious_config do
    %{
      @default_config
      | qubit_spacing: 70,
        gate_width: 50,
        gate_height: 50,
        h_padding: 80,
        v_padding: 30,
        gate_spacing: 15,
        font_size: 18
    }
  end
end
