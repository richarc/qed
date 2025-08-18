# QED Drawing System

The QED Drawing System provides a flexible, extensible architecture for rendering quantum circuits as SVG diagrams. This system has been completely refactored to support easy addition of new quantum gates and operators through a configuration-based approach.

## Architecture Overview

The drawing system consists of several modular components:

- **`Draw`** - Main interface for circuit rendering
- **`GateConfig`** - Configuration system for gate appearance and behavior
- **`LayoutConfig`** - Layout parameters and positioning calculations
- **`Primitives`** - Reusable SVG drawing functions
- **`Drawable`** - Protocol for extensible gate rendering
- **`GateDrawer`** - Custom drawing functions for complex gates

## Quick Start

```elixir
# Create a quantum circuit
circuit = QED.QuantumCircuit.new(2, 1)
circuit = circuit |> QED.Operators.h(0) |> QED.Operators.cx(0, 1)

# Generate SVG (default format)
svg = QED.Draw.circuit(circuit)

# Generate PNG
png_data = QED.Draw.circuit(circuit, :png)

# With custom layout
svg = QED.Draw.circuit(circuit, :svg, %{layout: %{qubit_spacing: 60}})
png = QED.Draw.circuit(circuit, :png, %{width: 800, height: 600})
```

## Components

### GateConfig

Manages gate appearance and rendering properties:

```elixir
# Get gate configuration
config = QED.Draw.GateConfig.get_config(:x)
# => %{label: "X", color: "#FF69B4", type: :single_qubit, custom_drawer: nil}

# Check if gate is registered
QED.Draw.GateConfig.gate_registered?(:h)
# => true

# Get gates by type
single_qubit_gates = QED.Draw.GateConfig.get_gates_by_type(:single_qubit)
# => [:x, :y, :z, :h]
```

### LayoutConfig

Handles layout calculations and positioning:

```elixir
# Get default layout
layout = QED.Draw.LayoutConfig.default_config()

# Custom layout with overrides
layout = QED.Draw.LayoutConfig.get_config(%{qubit_spacing: 80})

# Preset layouts
compact = QED.Draw.LayoutConfig.compact_config()
spacious = QED.Draw.LayoutConfig.spacious_config()

# Calculate dimensions
{width, height} = QED.Draw.LayoutConfig.calculate_dimensions(3, 5, 2)
```

### Primitives

Low-level SVG drawing functions:

```elixir
# Draw a rectangular gate
rect = QED.Draw.Primitives.draw_rect_gate(10, 20, 40, 40, "X", "#FF69B4")

# Draw control elements
control_dot = QED.Draw.Primitives.draw_control_dot(50, 100)
target_circle = QED.Draw.Primitives.draw_target_circle(50, 150)

# Draw lines and text
line = QED.Draw.Primitives.draw_line(0, 0, 100, 100)
text = QED.Draw.Primitives.draw_text(50, 25, "Label", %{font_size: 16})

# PNG conversion
png_data = QED.Draw.convert_svg_to_png(svg_content)
png_with_size = QED.Draw.convert_svg_to_png(svg_content, %{width: 800})
```

## Output Formats

The drawing system supports two output formats:

### SVG (Scalable Vector Graphics)
- **Always available** - No external dependencies
- **Lightweight** - Text-based format
- **Scalable** - Vector graphics scale without quality loss
- **Web-friendly** - Can be embedded directly in HTML
- **Default format** - Used when no format is specified

```elixir
# Generate SVG
svg = QED.Draw.circuit(circuit)
svg = QED.Draw.circuit(circuit, :svg)
svg = QED.Draw.circuit(circuit, :svg, %{layout: %{qubit_spacing: 60}})
```

### PNG (Portable Network Graphics)
- **Requires external tools** - Either `rsvg-convert` or ImageMagick
- **Raster format** - Fixed resolution, larger file sizes
- **Universal compatibility** - Supported by all image viewers and editors
- **Customizable dimensions** - Can specify width and height

```elixir
# Generate PNG
png_data = QED.Draw.circuit(circuit, :png)
png_large = QED.Draw.circuit(circuit, :png, %{width: 800, height: 600})

# Save to file
File.write!("circuit.png", png_data)
```

### PNG Requirements

PNG generation requires one of the following tools:

**rsvg-convert (recommended):**
- Ubuntu/Debian: `sudo apt-get install librsvg2-bin`
- macOS: `brew install librsvg`
- CentOS/RHEL: `sudo yum install librsvg2-tools`
- Windows: Download from GNOME project

**ImageMagick:**
- Ubuntu/Debian: `sudo apt-get install imagemagick`
- macOS: `brew install imagemagick`
- CentOS/RHEL: `sudo yum install ImageMagick`
- Windows: Download from ImageMagick.org

### Format Detection

The system automatically detects available PNG converters and uses the best option:

1. **rsvg-convert** (preferred) - Faster, more reliable for SVG conversion
2. **ImageMagick convert** (fallback) - More universally available

If neither tool is available, PNG requests will raise a `RuntimeError` with installation instructions.

## Adding New Gates

### Method 1: Configuration-Based (Recommended)

For simple gates that use standard rectangular appearance:

1. **Add gate configuration** to `GateConfig`:
```elixir
@gate_configs Map.merge(@gate_configs, %{
  rx: %{label: "RX", color: "#FF6B6B", type: :single_qubit, custom_drawer: nil}
})
```

2. **Add operator function** to `Operators` module:
```elixir
def rx(%QuantumCircuit{} = circuit, qubit_index, angle) do
  instructions = circuit.instructions ++ [{:rx, qubit_index, angle}]
  %QuantumCircuit{circuit | instructions: instructions}
end
```

3. **Update instruction pattern matching** in `Draw` module:
```elixir
defp get_gate_type(instruction) do
  case instruction do
    {:rx, _, _} -> :rx
    # ... existing patterns
  end
end
```

### Method 2: Custom Drawing

For gates requiring special appearance:

1. **Add configuration with custom drawer**:
```elixir
swap: %{label: "SWAP", color: "#FFEAA7", type: :two_qubit, custom_drawer: :draw_swap}
```

2. **Implement custom drawing function** in `GateDrawer`:
```elixir
def draw_swap(qubit1, qubit2, position, layout_params) do
  # Custom drawing logic
  # Returns list of SVG element strings
end
```

3. **Wire up the custom drawer** in `Draw.apply_custom_drawer/5`

### Method 3: Protocol-Based (Maximum Flexibility)

For completely custom gate types:

```elixir
defmodule MyCustomGate do
  defstruct [:qubits, :params]
end

defimpl QED.Draw.Drawable, for: MyCustomGate do
  def draw(gate, position, layout_params) do
    # Your custom drawing logic
  end
  
  def bounding_box(gate, _position, layout_params) do
    %{width: 40, height: 40}
  end
  
  def multi_qubit?(gate) do
    length(gate.qubits) > 1
  end
end
```

## Layout Customization

### PNG Conversion Options

When generating PNG output, you can specify additional options:

```elixir
# Standard PNG
png = QED.Draw.circuit(circuit, :png)

# PNG with custom width
png = QED.Draw.circuit(circuit, :png, %{width: 800})

# PNG with custom height
png = QED.Draw.circuit(circuit, :png, %{height: 600})

# PNG with both dimensions
png = QED.Draw.circuit(circuit, :png, %{width: 800, height: 600})
```

**Available PNG Options:**
- `width`: Target width in pixels (maintains aspect ratio if height not specified)
- `height`: Target height in pixels (maintains aspect ratio if width not specified)
- Both `width` and `height`: Forces exact dimensions (may distort aspect ratio)

### Available Layout Parameters

```elixir
%{
  qubit_spacing: 50,     # Vertical space between qubit lines
  gate_width: 40,        # Width of gate rectangles
  gate_height: 40,       # Height of gate rectangles
  h_padding: 60,         # Horizontal padding
  v_padding: 20,         # Vertical padding
  gate_spacing: 10,      # Horizontal space between gates
  font_size: 16,         # Font size for labels
  label_offset: 10,      # Distance from labels to circuit
  line_width: 1          # Width of connecting lines
}
```

### Preset Layouts

- **`default_config()`** - Standard spacing and dimensions
- **`compact_config()`** - Smaller spacing for dense circuits
- **`spacious_config()`** - Larger spacing for presentations

## Gate Types

The system supports three main gate categories:

### Single Qubit Gates
- Standard rectangular appearance
- Examples: X, Y, Z, H, RX, RY, RZ
- Configuration: `type: :single_qubit`

### Two Qubit Gates
- Custom connection lines between qubits
- Examples: CNOT (CX), CZ, SWAP
- Configuration: `type: :two_qubit`

### Measurement Gates
- Connect qubit lines to classical bit lines
- Special measurement symbol
- Configuration: `type: :measurement`

## Error Handling

The system gracefully handles various error conditions:

### Drawing Errors
- **Unknown gates** are rendered with a "?" label and gray color
- **Invalid configurations** are validated and rejected
- **Missing layout parameters** use sensible defaults

### PNG Conversion Errors
- **Missing converters** raise `RuntimeError` with installation instructions
- **Conversion failures** include error details from the external tool
- **Invalid SVG input** is handled by the external converter

```elixir
try do
  png = QED.Draw.circuit(circuit, :png)
rescue
  RuntimeError -> 
    IO.puts("PNG conversion not available, using SVG instead")
    svg = QED.Draw.circuit(circuit, :svg)
end
```

## Testing

Each component includes comprehensive tests:

```bash
# Run all drawing tests
mix test test/draw_test.exs

# Run specific component tests
mix test test/draw_test.exs -k "GateConfig"
mix test test/draw_test.exs -k "LayoutConfig"
mix test test/draw_test.exs -k "Primitives"
```

## Performance Considerations

### SVG Generation
- **Fast** - Pure Elixir string manipulation
- **Memory efficient** - Generates strings directly
- **No external dependencies** - Always available
- **Scalable** - Performance scales linearly with circuit size

### PNG Generation
- **Slower** - Requires external process execution
- **Memory overhead** - SVG→PNG conversion in memory
- **External dependency** - Requires rsvg-convert or ImageMagick
- **File I/O** - May involve temporary files depending on converter

**Performance Comparison:**
- SVG: ~0.01ms per circuit (typical)
- PNG: ~10-50ms per circuit (depends on converter and size)
- PNG is approximately 10-100x slower than SVG

**Recommendations:**
- Use SVG for interactive applications and web display
- Use PNG for static reports, documentation, or legacy system compatibility
- Cache PNG results when generating many similar circuits

## Migration from Legacy System

The new system is backward compatible with existing circuits. Key improvements:

| Legacy System | New System |
|---------------|------------|
| Hard-coded gate functions | Configuration-based gates |
| Repeated SVG code | Reusable primitives |
| Fixed layout | Configurable layout |
| Difficult to extend | Protocol-based extensibility |
| Manual positioning | Automatic layout calculation |
| SVG only | SVG and PNG support |
| Fixed dimensions | Customizable output size |

### API Compatibility

All existing code continues to work without changes:

```elixir
# Legacy API (still works)
svg = QED.Draw.circuit(circuit)
svg = QED.Draw.circuit(circuit, %{layout: %{qubit_spacing: 60}})

# New API (additional functionality)
png = QED.Draw.circuit(circuit, :png)
svg = QED.Draw.circuit(circuit, :svg, %{layout: %{qubit_spacing: 60}})
```

## Examples

### Basic Usage Examples

```elixir
# Simple circuit
circuit = QED.QuantumCircuit.new(2, 1)
|> QED.Operators.h(0)
|> QED.Operators.cx(0, 1)

# Generate different formats
svg = QED.Draw.circuit(circuit, :svg)
png = QED.Draw.circuit(circuit, :png)

# Save to files
File.write!("circuit.svg", svg)
File.write!("circuit.png", png)
```

### Advanced Examples

See the examples directory for comprehensive demonstrations:
- `examples/adding_new_gates.exs` - Adding new gate types, custom drawing, protocol implementation
- `examples/output_formats.exs` - SVG and PNG generation, layout customization, performance comparison

### Integration Examples

```elixir
# Web application (Phoenix)
def show_circuit(conn, %{"id" => id}) do
  circuit = Circuits.get_circuit!(id)
  svg = QED.Draw.circuit(circuit, :svg)
  
  conn
  |> put_resp_content_type("image/svg+xml")
  |> send_resp(200, svg)
end

# Report generation
def generate_circuit_report(circuits) do
  png_images = Enum.map(circuits, fn circuit ->
    QED.Draw.circuit(circuit, :png, %{width: 600, height: 400})
  end)
  
  # Include PNGs in PDF report...
end

# Command line tool
defp save_circuit(circuit, filename) do
  case Path.extname(filename) do
    ".svg" -> 
      svg = QED.Draw.circuit(circuit, :svg)
      File.write!(filename, svg)
    
    ".png" -> 
      png = QED.Draw.circuit(circuit, :png)
      File.write!(filename, png)
    
    _ -> 
      {:error, "Unsupported format"}
  end
end
```

## Contributing

When adding new gates:

1. Follow the configuration-based approach when possible
2. Add appropriate tests
3. Update documentation
4. Ensure gates work with all layout presets
5. Validate gate configurations

For complex gates requiring custom drawing:

1. Implement in `GateDrawer` module
2. Use existing `Primitives` when possible
3. Follow SVG best practices
4. Test with different layouts
5. Document the drawing logic