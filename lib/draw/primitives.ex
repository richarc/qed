defmodule QED.Draw.Primitives do
  @moduledoc """
  Reusable SVG drawing primitives for quantum gates.

  This module provides low-level functions for drawing common SVG elements
  used in quantum circuit diagrams, such as rectangles, circles, lines, and text.
  """

  @doc """
  Draws a basic rectangular gate with text label.

  ## Parameters
  - `x`: X coordinate of the rectangle
  - `y`: Y coordinate of the rectangle
  - `width`: Width of the rectangle
  - `height`: Height of the rectangle
  - `label`: Text label to display in the center
  - `color`: Fill color of the rectangle

  ## Examples

      iex> QED.Draw.Primitives.draw_rect_gate(10, 20, 40, 40, "X", "#FF69B4")
      [
        "<rect x=\"10\" y=\"20\" width=\"40\" height=\"40\" fill=\"#FF69B4\" stroke=\"black\" />",
        "<text x=\"30\" y=\"44\" text-anchor=\"middle\" font-size=\"20\">X</text>"
      ]
  """
  @spec draw_rect_gate(number(), number(), number(), number(), String.t(), String.t()) :: [
          String.t()
        ]
  def draw_rect_gate(x, y, width, height, label, color) do
    center_x = x + width / 2
    # Offset for text baseline
    center_y = y + height / 2 + 4

    [
      "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" height=\"#{height}\" fill=\"#{color}\" stroke=\"black\" />",
      "<text x=\"#{center_x}\" y=\"#{center_y}\" text-anchor=\"middle\" font-size=\"20\">#{label}</text>"
    ]
  end

  @doc """
  Draws a control dot for controlled gates.

  ## Parameters
  - `x`: X coordinate of the center
  - `y`: Y coordinate of the center
  - `radius`: Radius of the control dot (default: 5)

  ## Examples

      iex> QED.Draw.Primitives.draw_control_dot(50, 100)
      "<circle cx=\"50\" cy=\"100\" r=\"5\" fill=\"black\" />"
  """
  @spec draw_control_dot(number(), number(), number()) :: String.t()
  def draw_control_dot(x, y, radius \\ 5) do
    "<circle cx=\"#{x}\" cy=\"#{y}\" r=\"#{radius}\" fill=\"black\" />"
  end

  @doc """
  Draws a target circle (⊕ symbol) for controlled gates.

  ## Parameters
  - `x`: X coordinate of the center
  - `y`: Y coordinate of the center
  - `radius`: Radius of the target circle (default: 15)

  ## Examples

      iex> QED.Draw.Primitives.draw_target_circle(50, 100, 15)
      [
        "<circle cx=\"50\" cy=\"100\" r=\"15\" fill=\"none\" stroke=\"black\" />",
        "<line x1=\"40\" y1=\"100\" x2=\"60\" y2=\"100\" stroke=\"black\" />",
        "<line x1=\"50\" y1=\"90\" x2=\"50\" y2=\"110\" stroke=\"black\" />"
      ]
  """
  @spec draw_target_circle(number(), number(), number()) :: [String.t()]
  def draw_target_circle(x, y, radius \\ 15) do
    # Make lines slightly smaller than radius
    line_length = radius * 0.67

    [
      "<circle cx=\"#{x}\" cy=\"#{y}\" r=\"#{radius}\" fill=\"none\" stroke=\"black\" />",
      "<line x1=\"#{x - line_length}\" y1=\"#{y}\" x2=\"#{x + line_length}\" y2=\"#{y}\" stroke=\"black\" />",
      "<line x1=\"#{x}\" y1=\"#{y - line_length}\" x2=\"#{x}\" y2=\"#{y + line_length}\" stroke=\"black\" />"
    ]
  end

  @doc """
  Draws a line between two points.

  ## Parameters
  - `x1`: X coordinate of the start point
  - `y1`: Y coordinate of the start point
  - `x2`: X coordinate of the end point
  - `y2`: Y coordinate of the end point
  - `stroke`: Color of the line (default: "black")
  - `stroke_width`: Width of the line (default: 1)

  ## Examples

      iex> QED.Draw.Primitives.draw_line(10, 20, 30, 40)
      "<line x1=\"10\" y1=\"20\" x2=\"30\" y2=\"40\" stroke=\"black\" stroke-width=\"1\" />"
  """
  @spec draw_line(number(), number(), number(), number(), String.t(), number()) :: String.t()
  def draw_line(x1, y1, x2, y2, stroke \\ "black", stroke_width \\ 1) do
    "<line x1=\"#{x1}\" y1=\"#{y1}\" x2=\"#{x2}\" y2=\"#{y2}\" stroke=\"#{stroke}\" stroke-width=\"#{stroke_width}\" />"
  end

  @doc """
  Draws a dashed line between two points.

  ## Parameters
  - `x1`: X coordinate of the start point
  - `y1`: Y coordinate of the start point
  - `x2`: X coordinate of the end point
  - `y2`: Y coordinate of the end point
  - `stroke`: Color of the line (default: "black")
  - `dash_pattern`: SVG dash pattern (default: "5,5")

  ## Examples

      iex> QED.Draw.Primitives.draw_dashed_line(10, 20, 30, 40)
      "<line x1=\"10\" y1=\"20\" x2=\"30\" y2=\"40\" stroke=\"black\" stroke-dasharray=\"5,5\" />"
  """
  @spec draw_dashed_line(number(), number(), number(), number(), String.t(), String.t()) ::
          String.t()
  def draw_dashed_line(x1, y1, x2, y2, stroke \\ "black", dash_pattern \\ "5,5") do
    "<line x1=\"#{x1}\" y1=\"#{y1}\" x2=\"#{x2}\" y2=\"#{y2}\" stroke=\"#{stroke}\" stroke-dasharray=\"#{dash_pattern}\" />"
  end

  @doc """
  Draws text at a specified position.

  ## Parameters
  - `x`: X coordinate
  - `y`: Y coordinate
  - `text`: Text content
  - `options`: Map of text options (font_size, anchor, color, etc.)

  ## Examples

      iex> QED.Draw.Primitives.draw_text(50, 100, "q0:", %{font_size: 16, anchor: "end"})
      "<text x=\"50\" y=\"100\" text-anchor=\"end\" font-size=\"16\" fill=\"black\">q0:</text>"
  """
  @spec draw_text(number(), number(), String.t(), map()) :: String.t()
  def draw_text(x, y, text, options \\ %{}) do
    font_size = Map.get(options, :font_size, 20)
    anchor = Map.get(options, :anchor, "middle")
    color = Map.get(options, :color, "black")

    "<text x=\"#{x}\" y=\"#{y}\" text-anchor=\"#{anchor}\" font-size=\"#{font_size}\" fill=\"#{color}\">#{text}</text>"
  end

  @doc """
  Draws a circle.

  ## Parameters
  - `x`: X coordinate of the center
  - `y`: Y coordinate of the center
  - `radius`: Radius of the circle
  - `fill`: Fill color (default: "none")
  - `stroke`: Stroke color (default: "black")

  ## Examples

      iex> QED.Draw.Primitives.draw_circle(50, 100, 10, "red")
      "<circle cx=\"50\" cy=\"100\" r=\"10\" fill=\"red\" stroke=\"black\" />"
  """
  @spec draw_circle(number(), number(), number(), String.t(), String.t()) :: String.t()
  def draw_circle(x, y, radius, fill \\ "none", stroke \\ "black") do
    "<circle cx=\"#{x}\" cy=\"#{y}\" r=\"#{radius}\" fill=\"#{fill}\" stroke=\"#{stroke}\" />"
  end

  @doc """
  Draws a measurement symbol (arc with arrow).

  ## Parameters
  - `x`: X coordinate of the center
  - `y`: Y coordinate of the center
  - `radius`: Radius of the arc (default: 15)

  ## Examples

      iex> QED.Draw.Primitives.draw_measurement_symbol(50, 100)
      [
        "<path d=\"M 35 100 A 15 15 0 0 1 65 100\" stroke=\"black\" fill=\"none\" />",
        "<line x1=\"60\" y1=\"105\" x2=\"65\" y2=\"100\" stroke=\"black\" />",
        "<line x1=\"60\" y1=\"95\" x2=\"65\" y2=\"100\" stroke=\"black\" />"
      ]
  """
  @spec draw_measurement_symbol(number(), number(), number()) :: [String.t()]
  def draw_measurement_symbol(x, y, radius \\ 15) do
    # Draw an arc from left to right
    start_x = x - radius
    end_x = x + radius

    # Arrow pointing to the right
    arrow_x = end_x
    arrow_y = y
    arrow_left_x = arrow_x - 5
    arrow_up_y = arrow_y - 5
    arrow_down_y = arrow_y + 5

    [
      "<path d=\"M #{start_x} #{y} A #{radius} #{radius} 0 0 1 #{end_x} #{y}\" stroke=\"black\" fill=\"none\" />",
      "<line x1=\"#{arrow_left_x}\" y1=\"#{arrow_up_y}\" x2=\"#{arrow_x}\" y2=\"#{arrow_y}\" stroke=\"black\" />",
      "<line x1=\"#{arrow_left_x}\" y1=\"#{arrow_down_y}\" x2=\"#{arrow_x}\" y2=\"#{arrow_y}\" stroke=\"black\" />"
    ]
  end

  @doc """
  Groups multiple SVG elements together.

  ## Parameters
  - `elements`: List of SVG element strings
  - `group_id`: Optional ID for the group

  ## Examples

      iex> elements = ["<circle cx=\"50\" cy=\"100\" r=\"5\" fill=\"black\" />"]
      iex> QED.Draw.Primitives.group_elements(elements, "gate-1")
      ["<g id=\"gate-1\">", "<circle cx=\"50\" cy=\"100\" r=\"5\" fill=\"black\" />", "</g>"]
  """
  @spec group_elements([String.t()], String.t() | nil) :: [String.t()]
  def group_elements(elements, group_id \\ nil) do
    opening_tag =
      case group_id do
        nil -> "<g>"
        id -> "<g id=\"#{id}\">"
      end

    [opening_tag] ++ List.flatten(elements) ++ ["</g>"]
  end
end
