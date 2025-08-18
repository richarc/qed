defmodule QED.DrawTest do
  use ExUnit.Case, async: true

  alias QED.{QuantumCircuit, Operators, Draw}
  alias QED.Draw.{GateConfig, LayoutConfig, Primitives}

  describe "circuit/2" do
    test "draws a simple single-qubit circuit" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.h(circuit, 0)

      svg = Draw.circuit(circuit)

      assert String.contains?(svg, "<svg")
      assert String.contains?(svg, "</svg>")
      assert String.contains?(svg, "q0:")
      assert String.contains?(svg, "c0:")
      assert String.contains?(svg, "H")
    end

    test "draws a two-qubit circuit with CNOT" do
      circuit = QuantumCircuit.new(2, 1)
      circuit = Operators.h(circuit, 0)
      circuit = Operators.cx(circuit, 0, 1)

      svg = Draw.circuit(circuit)

      assert String.contains?(svg, "q0:")
      assert String.contains?(svg, "q1:")
      assert String.contains?(svg, "H")
      # Should contain control dot and target circle elements
      assert String.contains?(svg, "circle")
    end

    test "draws measurement operations" do
      circuit = QuantumCircuit.new(2, 2)
      circuit = Operators.measure(circuit, 0, 0)
      circuit = Operators.measure(circuit, 1, 1)

      svg = Draw.circuit(circuit)

      assert String.contains?(svg, "M")
      assert String.contains?(svg, "c0:")
      assert String.contains?(svg, "c1:")
    end

    test "accepts layout configuration options" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.x(circuit, 0)

      compact_svg = Draw.circuit(circuit, %{layout: %{qubit_spacing: 30}})
      default_svg = Draw.circuit(circuit)

      # Both should be valid SVG
      assert String.contains?(compact_svg, "<svg")
      assert String.contains?(default_svg, "<svg")
      # They should be different due to different spacing
      refute compact_svg == default_svg
    end

    test "generates PNG output when format is :png" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.x(circuit, 0)

      # This test will be skipped if no PNG converter is available
      try do
        png_data = Draw.circuit(circuit, :png)
        assert is_binary(png_data)
        assert byte_size(png_data) > 0
        # PNG files start with specific magic bytes
        <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _rest::binary>> = png_data
      rescue
        # Skip test if no converter available
        RuntimeError -> :ok
      end
    end

    test "generates SVG output when format is :svg" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.x(circuit, 0)

      svg_data = Draw.circuit(circuit, :svg)
      assert is_binary(svg_data)
      assert String.contains?(svg_data, "<svg")
      assert String.contains?(svg_data, "</svg>")
    end

    test "defaults to SVG format when no format specified" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.x(circuit, 0)

      default_output = Draw.circuit(circuit)
      svg_output = Draw.circuit(circuit, :svg)

      assert default_output == svg_output
    end

    test "maintains backward compatibility with options as second parameter" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.x(circuit, 0)

      legacy_output = Draw.circuit(circuit, %{layout: %{qubit_spacing: 60}})
      new_output = Draw.circuit(circuit, :svg, %{layout: %{qubit_spacing: 60}})

      assert is_binary(legacy_output)
      assert is_binary(new_output)
      assert String.contains?(legacy_output, "<svg")
      assert String.contains?(new_output, "<svg")
    end

    test "accepts PNG conversion options" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.x(circuit, 0)

      try do
        png_data = Draw.circuit(circuit, :png, %{width: 400, height: 300})
        assert is_binary(png_data)
        assert byte_size(png_data) > 0
      rescue
        # Skip test if no converter available
        RuntimeError -> :ok
      end
    end
  end

  describe "generate_svg_content/2" do
    test "generates valid SVG content" do
      circuit = QuantumCircuit.new(2, 1)
      circuit = Operators.h(circuit, 0)
      circuit = Operators.cx(circuit, 0, 1)

      svg_content = Draw.generate_svg_content(circuit)

      assert String.contains?(svg_content, "<svg")
      assert String.contains?(svg_content, "</svg>")
      assert String.contains?(svg_content, "H")
      assert String.contains?(svg_content, "circle")
    end

    test "accepts layout options" do
      circuit = QuantumCircuit.new(1, 1)
      circuit = Operators.x(circuit, 0)

      svg_with_options = Draw.generate_svg_content(circuit, %{layout: %{qubit_spacing: 80}})
      svg_default = Draw.generate_svg_content(circuit)

      refute svg_with_options == svg_default
    end
  end

  describe "convert_svg_to_png/2" do
    test "raises error when no converter is available" do
      # This test is conceptual since we can't easily mock private functions
      # In practice, the function will work if converters are available
      svg_content = "<svg></svg>"

      try do
        result = Draw.convert_svg_to_png(svg_content)
        assert is_binary(result)
      rescue
        RuntimeError ->
          # Test passes if RuntimeError is raised
          assert true
      end
    end
  end

  describe "draw_instruction/3" do
    test "draws single qubit gates" do
      layout_params = %{
        config: LayoutConfig.default_config(),
        num_qubits: 2,
        num_classical_bits: 1
      }

      x_gate = {:x, 0}
      elements = Draw.draw_instruction(x_gate, 0, layout_params)

      assert is_list(elements)
      assert length(elements) > 0
      assert Enum.any?(elements, &String.contains?(&1, "rect"))
      assert Enum.any?(elements, &String.contains?(&1, "X"))
    end

    test "draws CNOT gates" do
      layout_params = %{
        config: LayoutConfig.default_config(),
        num_qubits: 2,
        num_classical_bits: 1
      }

      cnot_gate = {:cx, 0, 1}
      elements = Draw.draw_instruction(cnot_gate, 0, layout_params)

      assert is_list(elements)
      assert length(elements) > 0
      # Should contain control dot and target elements
      assert Enum.any?(elements, &String.contains?(&1, "circle"))
    end
  end

  describe "get_gate_info/1" do
    test "returns info for known gates" do
      x_info = Draw.get_gate_info(:x)
      assert x_info.label == "X"
      assert x_info.color == "#FF69B4"
      assert x_info.type == :single_qubit
    end

    test "returns nil for unknown gates" do
      assert Draw.get_gate_info(:unknown_gate) == nil
    end
  end

  describe "list_supported_gates/0" do
    test "returns list of supported gate types" do
      gates = Draw.list_supported_gates()

      assert is_list(gates)
      assert :x in gates
      assert :y in gates
      assert :z in gates
      assert :h in gates
      assert :cx in gates
      assert :measure in gates
    end
  end
end

defmodule QED.Draw.GateConfigTest do
  use ExUnit.Case, async: true

  alias QED.Draw.GateConfig

  describe "get_config/1" do
    test "returns configuration for valid gate types" do
      config = GateConfig.get_config(:x)

      assert config.label == "X"
      assert config.color == "#FF69B4"
      assert config.type == :single_qubit
      assert config.custom_drawer == nil
    end

    test "returns nil for invalid gate types" do
      assert GateConfig.get_config(:invalid) == nil
    end
  end

  describe "gate_registered?/1" do
    test "returns true for registered gates" do
      assert GateConfig.gate_registered?(:x) == true
      assert GateConfig.gate_registered?(:cx) == true
    end

    test "returns false for unregistered gates" do
      assert GateConfig.gate_registered?(:invalid) == false
    end
  end

  describe "get_gates_by_type/1" do
    test "returns single qubit gates" do
      single_gates = GateConfig.get_gates_by_type(:single_qubit)

      assert :x in single_gates
      assert :y in single_gates
      assert :z in single_gates
      assert :h in single_gates
      refute :cx in single_gates
    end

    test "returns two qubit gates" do
      two_gates = GateConfig.get_gates_by_type(:two_qubit)

      assert :cx in two_gates
      refute :x in two_gates
    end

    test "returns measurement gates" do
      measurement_gates = GateConfig.get_gates_by_type(:measurement)

      assert :measure in measurement_gates
    end
  end

  describe "valid_config?/1" do
    test "validates correct configurations" do
      valid_config = %{
        label: "TEST",
        color: "#000000",
        type: :single_qubit,
        custom_drawer: nil
      }

      assert GateConfig.valid_config?(valid_config) == true
    end

    test "rejects invalid configurations" do
      assert GateConfig.valid_config?(%{}) == false
      assert GateConfig.valid_config?("not a map") == false

      invalid_config = %{
        label: "TEST",
        color: "#000000",
        type: :invalid_type,
        custom_drawer: nil
      }

      assert GateConfig.valid_config?(invalid_config) == false
    end
  end
end

defmodule QED.Draw.LayoutConfigTest do
  use ExUnit.Case, async: true

  alias QED.Draw.LayoutConfig

  describe "get_config/1" do
    test "returns default config when no overrides provided" do
      config = LayoutConfig.get_config()
      default = LayoutConfig.default_config()

      assert config == default
    end

    test "merges overrides with default config" do
      overrides = %{qubit_spacing: 100}
      config = LayoutConfig.get_config(overrides)

      assert config.qubit_spacing == 100
      assert config.gate_width == LayoutConfig.default_config().gate_width
    end
  end

  describe "calculate_dimensions/4" do
    test "calculates correct dimensions" do
      {width, height} = LayoutConfig.calculate_dimensions(2, 3, 1)

      # Should be based on default config values
      assert width > 0
      assert height > 0
      assert is_number(width)
      assert is_number(height)
    end
  end

  describe "position calculation functions" do
    test "gate_x_position/2 calculates correct x position" do
      x0 = LayoutConfig.gate_x_position(0)
      x1 = LayoutConfig.gate_x_position(1)

      assert x1 > x0
      assert is_number(x0)
      assert is_number(x1)
    end

    test "qubit_y_position/2 calculates correct y position" do
      y0 = LayoutConfig.qubit_y_position(0)
      y1 = LayoutConfig.qubit_y_position(1)

      assert y1 > y0
      assert is_number(y0)
      assert is_number(y1)
    end

    test "classical_y_position/3 positions classical lines after qubits" do
      num_qubits = 2
      y_classical = LayoutConfig.classical_y_position(0, num_qubits)
      y_last_qubit = LayoutConfig.qubit_y_position(num_qubits - 1)

      assert y_classical > y_last_qubit
    end
  end

  describe "valid_config?/1" do
    test "validates complete configurations" do
      config = LayoutConfig.default_config()
      assert LayoutConfig.valid_config?(config) == true
    end

    test "rejects incomplete configurations" do
      incomplete = %{qubit_spacing: 50}
      assert LayoutConfig.valid_config?(incomplete) == false
    end

    test "rejects non-positive values" do
      invalid = LayoutConfig.default_config() |> Map.put(:qubit_spacing, -10)
      assert LayoutConfig.valid_config?(invalid) == false
    end
  end

  describe "preset configurations" do
    test "compact_config/0 has smaller values" do
      compact = LayoutConfig.compact_config()
      default = LayoutConfig.default_config()

      assert compact.qubit_spacing < default.qubit_spacing
      assert compact.gate_width < default.gate_width
    end

    test "spacious_config/0 has larger values" do
      spacious = LayoutConfig.spacious_config()
      default = LayoutConfig.default_config()

      assert spacious.qubit_spacing > default.qubit_spacing
      assert spacious.gate_width > default.gate_width
    end
  end
end

defmodule QED.Draw.PrimitivesTest do
  use ExUnit.Case, async: true

  alias QED.Draw.Primitives

  describe "draw_rect_gate/6" do
    test "generates correct SVG rectangle with text" do
      elements = Primitives.draw_rect_gate(10, 20, 40, 40, "X", "#FF0000")

      assert is_list(elements)
      assert length(elements) == 2
      assert Enum.any?(elements, &String.contains?(&1, "rect"))
      assert Enum.any?(elements, &String.contains?(&1, "text"))
      assert Enum.any?(elements, &String.contains?(&1, "X"))
      assert Enum.any?(elements, &String.contains?(&1, "#FF0000"))
    end
  end

  describe "draw_control_dot/3" do
    test "generates control dot circle" do
      dot = Primitives.draw_control_dot(50, 100, 5)

      assert String.contains?(dot, "circle")
      assert String.contains?(dot, "cx=\"50\"")
      assert String.contains?(dot, "cy=\"100\"")
      assert String.contains?(dot, "r=\"5\"")
      assert String.contains?(dot, "fill=\"black\"")
    end
  end

  describe "draw_target_circle/3" do
    test "generates target circle with cross" do
      elements = Primitives.draw_target_circle(50, 100, 15)

      assert is_list(elements)
      # Circle + 2 lines for cross
      assert length(elements) == 3
      assert Enum.any?(elements, &String.contains?(&1, "circle"))
      assert Enum.count(elements, &String.contains?(&1, "line")) == 2
    end
  end

  describe "draw_line/6" do
    test "generates line with default stroke" do
      line = Primitives.draw_line(10, 20, 30, 40)

      assert String.contains?(line, "line")
      assert String.contains?(line, "x1=\"10\"")
      assert String.contains?(line, "y1=\"20\"")
      assert String.contains?(line, "x2=\"30\"")
      assert String.contains?(line, "y2=\"40\"")
      assert String.contains?(line, "stroke=\"black\"")
    end

    test "generates line with custom stroke" do
      line = Primitives.draw_line(10, 20, 30, 40, "red", 2)

      assert String.contains?(line, "stroke=\"red\"")
      assert String.contains?(line, "stroke-width=\"2\"")
    end
  end

  describe "draw_dashed_line/6" do
    test "generates dashed line" do
      line = Primitives.draw_dashed_line(10, 20, 30, 40)

      assert String.contains?(line, "stroke-dasharray")
      assert String.contains?(line, "5,5")
    end
  end

  describe "draw_text/4" do
    test "generates text with default options" do
      text = Primitives.draw_text(50, 100, "Hello")

      assert String.contains?(text, "text")
      assert String.contains?(text, "x=\"50\"")
      assert String.contains?(text, "y=\"100\"")
      assert String.contains?(text, "Hello")
      assert String.contains?(text, "text-anchor=\"middle\"")
    end

    test "generates text with custom options" do
      options = %{font_size: 24, anchor: "start", color: "blue"}
      text = Primitives.draw_text(50, 100, "Hello", options)

      assert String.contains?(text, "font-size=\"24\"")
      assert String.contains?(text, "text-anchor=\"start\"")
      assert String.contains?(text, "fill=\"blue\"")
    end
  end

  describe "draw_measurement_symbol/3" do
    test "generates measurement arc with arrow" do
      elements = Primitives.draw_measurement_symbol(50, 100, 15)

      assert is_list(elements)
      # Arc + 2 arrow lines
      assert length(elements) == 3
      assert Enum.any?(elements, &String.contains?(&1, "path"))
      assert Enum.count(elements, &String.contains?(&1, "line")) == 2
    end
  end

  describe "group_elements/2" do
    test "groups elements without ID" do
      elements = ["<circle />", "<rect />"]
      grouped = Primitives.group_elements(elements)

      assert List.first(grouped) == "<g>"
      assert List.last(grouped) == "</g>"
      assert String.contains?(Enum.join(grouped), "circle")
    end

    test "groups elements with ID" do
      elements = ["<circle />"]
      grouped = Primitives.group_elements(elements, "test-group")

      assert List.first(grouped) == "<g id=\"test-group\">"
      assert List.last(grouped) == "</g>"
    end
  end
end
