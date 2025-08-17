# QED

A Quantum Computing Simulator built in Elixir.

QED is a simple quantum computing simulator that allows you to build and simulate quantum circuits. It provides a simple API for creating circuits, adding gates, and running simulations.

Note: this is a very early and rough and is a project for me to learn Elixir and nx and not intended for any serious use (not yet any way)

## Application Structure

The application is structured into several modules:

- `QED`: The main API module for the QED simulator. It provides a simple interface for creating circuits, adding gates, and running simulations.
- `QED.QuantumCircuit`: Defines the `QED.QuantumCircuit` struct and functions for creating a new quantum circuit. A circuit contains qubits, classical bits, a state vector, and a list of instructions (gates).
- `QED.Qubit`: Defines functions for creating qubits, which are initialized in the |0> state.
- `QED.Operators`: Contains functions for applying quantum gates (X, Y, Z, H, CNOT) to a quantum circuit.
- `QED.Simulation`: Handles the simulation of the quantum circuit. It calculates the final state vector and probabilities of the measurement outcomes.
- `QED.Draw`: Provides functions to draw the quantum circuit as an SVG image and to plot the simulation results using `VegaLite`.
- `QED.Qmath`: Contains mathematical helper functions, such as the Kronecker product, used in the simulations.

## Usage

Here is a simple example of how to create a Bell state circuit, simulate it, and draw it.

```elixir
# Create a new circuit with 2 qubits and 2 classical bits
circuit = QED.new_circuit(2, 2)

# Add a Hadamard gate to the first qubit
|> QED.h(0)

# Add a CNOT gate with the first qubit as control and the second as target
|> QED.cx(0, 1)

# Add a measurement operation
|> QED.measure(0, 0)
|> QED.measure(1, 1)

# Run the simulation for 1000 shots
results = QED.run(circuit, 1000)

# Print the results
IO.inspect(results)

# Generate an SVG of the circuit
svg = QED.draw(circuit)
File.write("circuit.svg", svg)

# Generate a plot of the results
plot_spec = QED.plot(results)
File.write("plot.json", plot_spec)
```

## Dependencies

QED relies on the following Elixir packages:

- `nx`: For numerical computation and tensor operations.
- `vega_lite`: For creating plots and visualizations of the simulation results.
- `jason`: For JSON encoding, used by `vega_lite`.

## Installation

To use QED in your project, add it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:qed, git: "https://github.com/richarc/qed.git"}
  ]
end
```

## Testing

To run the test suite, use the following command:

```bash
mix test
```
