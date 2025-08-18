defmodule QED.Draw.GateConfig do
  @moduledoc """
  Configuration for quantum gate rendering properties.

  This module provides a centralized way to define how quantum gates should be
  rendered in circuit diagrams, including their colors, labels, and drawing types.
  """

  @type gate_type :: :single_qubit | :two_qubit | :measurement
  @type gate_config :: %{
          label: String.t(),
          color: String.t(),
          type: gate_type(),
          custom_drawer: atom() | nil
        }

  @gate_configs %{
    x: %{label: "X", color: "#FF69B4", type: :single_qubit, custom_drawer: nil},
    y: %{label: "Y", color: "#FFD700", type: :single_qubit, custom_drawer: nil},
    z: %{label: "Z", color: "#00FFFF", type: :single_qubit, custom_drawer: nil},
    h: %{label: "H", color: "#ADFF2F", type: :single_qubit, custom_drawer: nil},
    cx: %{label: "CX", color: "#FF0000", type: :two_qubit, custom_drawer: :draw_cnot},
    measure: %{label: "M", color: "#FFA500", type: :measurement, custom_drawer: :draw_measurement}
  }

  @doc """
  Gets the configuration for a specific gate type.

  ## Examples

      iex> QED.Draw.GateConfig.get_config(:x)
      %{label: "X", color: "#FF69B4", type: :single_qubit, custom_drawer: nil}

      iex> QED.Draw.GateConfig.get_config(:unknown)
      nil
  """
  @spec get_config(atom()) :: gate_config() | nil
  def get_config(gate_type) when is_atom(gate_type) do
    Map.get(@gate_configs, gate_type)
  end

  @doc """
  Gets all registered gate configurations.

  ## Examples

      iex> configs = QED.Draw.GateConfig.get_all_configs()
      iex> Map.has_key?(configs, :x)
      true
  """
  @spec get_all_configs() :: %{atom() => gate_config()}
  def get_all_configs, do: @gate_configs

  @doc """
  Checks if a gate type is registered.

  ## Examples

      iex> QED.Draw.GateConfig.gate_registered?(:x)
      true

      iex> QED.Draw.GateConfig.gate_registered?(:unknown)
      false
  """
  @spec gate_registered?(atom()) :: boolean()
  def gate_registered?(gate_type) when is_atom(gate_type) do
    Map.has_key?(@gate_configs, gate_type)
  end

  @doc """
  Gets the list of all registered gate types.

  ## Examples

      iex> gate_types = QED.Draw.GateConfig.get_gate_types()
      iex> :x in gate_types
      true
  """
  @spec get_gate_types() :: [atom()]
  def get_gate_types do
    Map.keys(@gate_configs)
  end

  @doc """
  Gets gates by their type category.

  ## Examples

      iex> single_gates = QED.Draw.GateConfig.get_gates_by_type(:single_qubit)
      iex> :x in single_gates
      true
  """
  @spec get_gates_by_type(gate_type()) :: [atom()]
  def get_gates_by_type(type) when type in [:single_qubit, :two_qubit, :measurement] do
    @gate_configs
    |> Enum.filter(fn {_gate, config} -> config.type == type end)
    |> Enum.map(fn {gate, _config} -> gate end)
  end

  @doc """
  Validates a gate configuration.

  ## Examples

      iex> config = %{label: "TEST", color: "#000000", type: :single_qubit, custom_drawer: nil}
      iex> QED.Draw.GateConfig.valid_config?(config)
      true

      iex> QED.Draw.GateConfig.valid_config?(%{})
      false
  """
  @spec valid_config?(map()) :: boolean()
  def valid_config?(config) when is_map(config) do
    required_keys = [:label, :color, :type, :custom_drawer]
    valid_types = [:single_qubit, :two_qubit, :measurement]

    Enum.all?(required_keys, &Map.has_key?(config, &1)) and
      is_binary(config[:label]) and
      is_binary(config[:color]) and
      config[:type] in valid_types and
      (is_nil(config[:custom_drawer]) or is_atom(config[:custom_drawer]))
  end

  def valid_config?(_), do: false
end
