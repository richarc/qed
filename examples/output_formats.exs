# Example: Circuit Drawing with Multiple Output Formats
#
# This example demonstrates how to generate quantum circuit diagrams
# in both SVG and PNG formats using the enhanced drawing system.

alias QED.{QuantumCircuit, Operators, Draw}

IO.puts("=== QED Circuit Drawing Formats Example ===\n")

# Create a sample quantum circuit
IO.puts("Creating a sample quantum circuit...")
circuit = QuantumCircuit.new(3, 2)

# Add some gates to make it interesting
circuit = circuit
|> Operators.h(0)                    # Hadamard on qubit 0
|> Operators.x(1)                    # Pauli-X on qubit 1
|> Operators.cx(0, 1)                # CNOT from qubit 0 to 1
|> Operators.h(2)                    # Hadamard on qubit 2
|> Operators.cx(1, 2)                # CNOT from qubit 1 to 2
|> Operators.measure(0, 0)           # Measure qubit 0 to classical bit 0
|> Operators.measure(2, 1)           # Measure qubit 2 to classical bit 1

IO.puts("Circuit created with #{length(circuit.instructions)} instructions")
IO.puts("Qubits: #{length(circuit.qubits)}, Classical bits: #{length(circuit.classical_bits)}\n")

# Generate SVG output (default format)
IO.puts("=== SVG Output (Default Format) ===")
svg_content = Draw.circuit(circuit)
IO.puts("Generated SVG with #{String.length(svg_content)} characters")
IO.puts("Preview (first 200 characters):")
IO.puts("#{String.slice(svg_content, 0, 200)}...\n")

# Alternative ways to generate SVG
svg_explicit = Draw.circuit(circuit, :svg)
svg_with_options = Draw.circuit(circuit, :svg, %{layout: %{qubit_spacing: 60}})

IO.puts("SVG lengths:")
IO.puts("  Default: #{String.length(svg_content)} chars")
IO.puts("  Explicit :svg: #{String.length(svg_explicit)} chars")
IO.puts("  With options: #{String.length(svg_with_options)} chars\n")

# Save SVG to file
svg_filename = "/tmp/quantum_circuit.svg"
File.write!(svg_filename, svg_content)
IO.puts("SVG saved to: #{svg_filename}")

# Generate PNG output
IO.puts("\n=== PNG Output ===")
try do
  # Check if PNG conversion is available
  png_data = Draw.circuit(circuit, :png)
  IO.puts("✓ PNG generation successful!")
  IO.puts("Generated PNG with #{byte_size(png_data)} bytes")

  # Verify PNG magic bytes
  case png_data do
    <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _rest::binary>> ->
      IO.puts("✓ Valid PNG format detected")
    _ ->
      IO.puts("⚠ Unexpected PNG format")
  end

  # Save PNG to file
  png_filename = "/tmp/quantum_circuit.png"
  File.write!(png_filename, png_data)
  IO.puts("PNG saved to: #{png_filename}")

  # Generate PNG with custom dimensions
  png_large = Draw.circuit(circuit, :png, %{width: 800, height: 600})
  large_filename = "/tmp/quantum_circuit_large.png"
  File.write!(large_filename, png_large)
  IO.puts("Large PNG (800x600) saved to: #{large_filename}")
  IO.puts("Large PNG size: #{byte_size(png_large)} bytes")

rescue
  RuntimeError ->
    IO.puts("✗ PNG generation failed:")
    IO.puts("  PNG conversion requires either 'rsvg-convert' or ImageMagick")
    IO.puts("\nTo enable PNG generation, install one of:")
    IO.puts("  • rsvg-convert: brew install librsvg (macOS) or apt-get install librsvg2-bin (Ubuntu)")
    IO.puts("  • ImageMagick: brew install imagemagick (macOS) or apt-get install imagemagick (Ubuntu)")
end

# Demonstrate different layout options
IO.puts("\n=== Layout Customization ===")

layouts = [
  {"Compact", Draw.LayoutConfig.compact_config()},
  {"Default", Draw.LayoutConfig.default_config()},
  {"Spacious", Draw.LayoutConfig.spacious_config()},
  {"Custom", %{qubit_spacing: 80, gate_width: 50, gate_height: 50}}
]

Enum.each(layouts, fn {name, layout_config} ->
  svg = Draw.circuit(circuit, :svg, %{layout: layout_config})
  IO.puts("#{name} layout: #{String.length(svg)} characters")

  # Extract dimensions from SVG
  case Regex.run(~r/width="(\d+)".*height="(\d+)"/, svg) do
    [_, width, height] ->
      IO.puts("  Dimensions: #{width}x#{height}")
    _ ->
      IO.puts("  Dimensions: Could not parse")
  end

  # Save each layout variant
  filename = "/tmp/circuit_#{String.downcase(name)}.svg"
  File.write!(filename, svg)
  IO.puts("  Saved to: #{filename}")
end)

# Performance comparison
IO.puts("\n=== Performance Comparison ===")

# Time SVG generation
{svg_time, _svg_result} = :timer.tc(fn ->
  Enum.each(1..100, fn _ -> Draw.circuit(circuit, :svg) end)
end)

IO.puts("SVG generation (100 iterations): #{svg_time / 1000} ms")
IO.puts("Average per SVG: #{svg_time / 100_000} ms")

# Time PNG generation (if available)
try do
  {png_time, _png_result} = :timer.tc(fn ->
    Enum.each(1..10, fn _ -> Draw.circuit(circuit, :png) end)
  end)

  IO.puts("PNG generation (10 iterations): #{png_time / 1000} ms")
  IO.puts("Average per PNG: #{png_time / 10_000} ms")
  IO.puts("PNG is ~#{Float.round(png_time / 10 / (svg_time / 100), 1)}x slower than SVG")
rescue
  RuntimeError ->
    IO.puts("PNG timing skipped (converter not available)")
end

# Demonstrate using the main QED interface
IO.puts("\n=== Using QED Main Interface ===")

# Using the delegated functions
qed_svg = QED.draw(circuit)
IO.puts("QED.draw(circuit): #{String.length(qed_svg)} characters")

try do
  qed_png = QED.draw(circuit, :png)
  IO.puts("QED.draw(circuit, :png): #{byte_size(qed_png)} bytes")

  qed_png_custom = QED.draw(circuit, :png, %{width: 600})
  IO.puts("QED.draw(circuit, :png, options): #{byte_size(qed_png_custom)} bytes")
rescue
  RuntimeError ->
    IO.puts("QED.draw PNG variants skipped (converter not available)")
end

# Summary
IO.puts("\n=== Summary ===")
IO.puts("✓ SVG generation: Always available, lightweight, scalable")
IO.puts("#{if File.exists?("/tmp/quantum_circuit.png"), do: "✓", else: "✗"} PNG generation: Requires external tools, larger files, raster format")
IO.puts("✓ Multiple layouts: Compact, default, spacious, custom")
IO.puts("✓ Backward compatibility: Existing code continues to work")
IO.puts("✓ Main interface: QED.draw/1, QED.draw/2, QED.draw/3")

IO.puts("\nFiles generated in /tmp/:")
["/tmp/quantum_circuit.svg", "/tmp/quantum_circuit.png", "/tmp/quantum_circuit_large.png",
 "/tmp/circuit_compact.svg", "/tmp/circuit_default.svg", "/tmp/circuit_spacious.svg", "/tmp/circuit_custom.svg"]
|> Enum.filter(&File.exists?/1)
|> Enum.each(fn filename ->
  stat = File.stat!(filename)
  IO.puts("  #{filename} (#{stat.size} bytes)")
end)

IO.puts("\n=== Example Complete ===")
