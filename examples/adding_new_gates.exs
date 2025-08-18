# Example: Adding New Gates to the QED Drawing System
#
# This example demonstrates how easy it is to extend the quantum circuit
# drawing system with new gate types using the new generic architecture.

# First, let's see how the current system works
alias QED.{QuantumCircuit, Operators, Draw}
alias QED.Draw.{GateConfig, LayoutConfig, Primitives, GateDrawer}

# Create a simple circuit with existing gates
circuit = QuantumCircuit.new(3, 2)
circuit = circuit |> Operators.h(0) |> Operators.cx(0, 1) |> Operators.measure(1, 0)

IO.puts("=== Current Circuit Drawing ===")
svg = Draw.circuit(circuit)
IO.puts("Generated SVG with #{String.length(svg)} characters")
IO.puts("Supported gates: #{Enum.join(Draw.list_supported_gates(), ", ")}")

# Now let's demonstrate how to add new gates
#
# Step 1: Add gate configurations for new gates
# (In a real implementation, you'd modify the GateConfig module)

IO.puts("\n=== Adding New Gate Types ===")

# Example: Adding rotation gates (RX, RY, RZ)
new_gate_configs = %{
  rx: %{label: "RX", color: "#FF6B6B", type: :single_qubit, custom_drawer: :draw_rotation},
  ry: %{label: "RY", color: "#4ECDC4", type: :single_qubit, custom_drawer: :draw_rotation},
  rz: %{label: "RZ", color: "#45B7D1", type: :single_qubit, custom_drawer: :draw_rotation},
  cz: %{label: "CZ", color: "#96CEB4", type: :two_qubit, custom_drawer: :draw_cz},
  swap: %{label: "SWAP", color: "#FFEAA7", type: :two_qubit, custom_drawer: :draw_swap},
  toffoli: %{label: "CCX", color: "#DDA0DD", type: :three_qubit, custom_drawer: :draw_toffoli}
}

# Validate the new configurations
Enum.each(new_gate_configs, fn {gate_type, config} ->
  if GateConfig.valid_config?(config) do
    IO.puts("✓ Valid config for #{gate_type}: #{config.label}")
  else
    IO.puts("✗ Invalid config for #{gate_type}")
  end
end)

# Step 2: Demonstrate extending operators (conceptual)
IO.puts("\n=== How to Add New Operators ===")
IO.puts("""
To add new operators to the system, you would:

1. Add the gate configuration to GateConfig:
   ```elixir
   @gate_configs Map.merge(@gate_configs, %{
     rx: %{label: "RX", color: "#FF6B6B", type: :single_qubit, custom_drawer: :draw_rotation}
   })
   ```

2. Add the operator function to the Operators module:
   ```elixir
   def rx(%QuantumCircuit{} = circuit, qubit_index, angle) do
     instructions = circuit.instructions ++ [{:rx, qubit_index, angle}]
     %QuantumCircuit{circuit | instructions: instructions}
   end
   ```

3. If needed, add custom drawing logic to GateDrawer:
   ```elixir
   def draw_rotation(gate_type, qubit_index, angle, config, position, layout_params) do
     # Custom drawing logic here
   end
   ```

4. Update the protocol implementation to handle the new instruction format:
   ```elixir
   defp get_gate_type(instruction) do
     case instruction do
       {:rx, _, _} -> :rx
       {:ry, _, _} -> :ry
       # ... existing patterns
     end
   end
   ```
""")

# Step 3: Demonstrate layout customization
IO.puts("\n=== Layout Customization ===")

# Show different layout presets
compact_layout = LayoutConfig.compact_config()
spacious_layout = LayoutConfig.spacious_config()
custom_layout = LayoutConfig.get_config(%{
  qubit_spacing: 80,
  gate_width: 60,
  gate_height: 50,
  h_padding: 100,
  v_padding: 40
})

IO.puts("Compact layout qubit spacing: #{compact_layout.qubit_spacing}")
IO.puts("Default layout qubit spacing: #{LayoutConfig.default_config().qubit_spacing}")
IO.puts("Spacious layout qubit spacing: #{spacious_layout.qubit_spacing}")
IO.puts("Custom layout qubit spacing: #{custom_layout.qubit_spacing}")

# Step 4: Demonstrate drawing primitives
IO.puts("\n=== Drawing Primitives Examples ===")

# Show how to use drawing primitives directly
rect_gate = Primitives.draw_rect_gate(0, 0, 40, 40, "NEW", "#FF0000")
control_dot = Primitives.draw_control_dot(20, 20, 5)
target_circle = Primitives.draw_target_circle(20, 60, 15)
connection_line = Primitives.draw_line(20, 35, 20, 45)

IO.puts("Rectangle gate elements: #{length(rect_gate)}")
IO.puts("Control dot: #{String.slice(control_dot, 0, 50)}...")
IO.puts("Target circle elements: #{length(target_circle)}")
IO.puts("Connection line: #{String.slice(connection_line, 0, 50)}...")

# Step 5: Show extensibility through protocols
IO.puts("\n=== Protocol-based Extensibility ===")
IO.puts("""
The Drawable protocol allows for maximum extensibility:

```elixir
# Define a new instruction type
defmodule MyCustomGate do
  defstruct [:qubit_indices, :parameters, :label]
end

# Implement the protocol for your custom type
defimpl QED.Draw.Drawable, for: MyCustomGate do
  def draw(gate, position, layout_params) do
    # Your custom drawing logic
    QED.Draw.GateDrawer.draw_custom(
      gate.qubit_indices,
      gate.label,
      "#CUSTOM",
      position,
      layout_params
    )
  end

  def bounding_box(gate, _position, layout_params) do
    # Calculate bounding box for your gate
    %{width: 40, height: 40 * length(gate.qubit_indices)}
  end

  def multi_qubit?(gate) do
    length(gate.qubit_indices) > 1
  end
end
```

This allows you to create completely custom gate types with their own
drawing behavior while still integrating seamlessly with the circuit
drawing system.
""")

# Step 6: Performance and maintenance benefits
IO.puts("\n=== Benefits of the New Architecture ===")
IO.puts("""
✓ Easy to add new gates - just update configuration
✓ Consistent styling across all gates
✓ Reusable drawing primitives reduce code duplication
✓ Configurable layouts for different display needs
✓ Protocol-based extensibility for custom gate types
✓ Separation of concerns - layout, styling, and drawing logic are separate
✓ Better testability - each component can be tested independently
✓ Type safety with proper error handling for unknown gates

The old system required modifying multiple functions for each new gate.
The new system requires only updating configuration in most cases.
""")

IO.puts("\n=== Example Complete ===")
