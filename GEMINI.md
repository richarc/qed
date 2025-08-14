## Project guidelines
This project is a quantum computing simulator written in the Elixir language and using the Elixir Nx library for numerical computation support when complex numbers are needed or matrix, vector or tensor calulations are required.

Qubit: The Qubit module holds the state of a Qubit and define core functions for setting the Qubit state. The qubit is always initialised in the ket0 (|0>) state.
The state of the Qubit may be changed by the Qubit.new(alpha, beta) funtion
the qubit state is is a Nx.Tensor of two complex values representing the qubit probabaility amplitudes.
When setting the state we must check that the values meet the normalisation contraints for qubits.

QuantumCircuit: The QuantumCircuit module holds the state of the circuit. The circuite module contans a list of qubits assigned to the circuit, a list of classical buits assigned to the circuit, the State Vector for the circuit and the instruction list for the circuit. The instruction list is a list of opperators that are applied to the circuit.

## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc
  you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark. Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option
- Elixir supports `if/else` but **does NOT support `if/else if` or `if/elsif`. **Never use `else if` or `elseif` in Elixir**, **always** use `cond` or `case` for multiple conditionals.

## Mix guidelines

- Read the docs and options before using tasks (by using `mix help task_name`)
- To debug test failures, run tests in a specific file with `mix test test/my_test.exs` or run all previously failed tests with `mix test --failed`
- `mix deps.clean --all` is **almost never needed**. **Avoid** using it unless you have good reason
