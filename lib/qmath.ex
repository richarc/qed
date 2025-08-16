defmodule QED.Qmath do
  import Nx.Defn

  @doc """
  Computes the Kronecker product of two vectors `u` and `v`.
  Both `u` and `v` should be Nx tensors of shape {m} and {n} respectively.
  Returns a tensor of shape {m * n}.
  We provide a defualt value for the second argument for the case when only one value is provided.
  """
  defn kronecker_product(a, b) do
    a_rank = Nx.rank(a)
    b_rank = Nx.rank(b)

    {a_rows, a_cols} = if a_rank == 1, do: {elem(Nx.shape(a), 0), 1}, else: Nx.shape(a)
    {b_rows, b_cols} = if b_rank == 1, do: {elem(Nx.shape(b), 0), 1}, else: Nx.shape(b)

    a_reshaped = Nx.reshape(a, {a_rows, a_cols})
    b_reshaped = Nx.reshape(b, {b_rows, b_cols})

    result = 
      Nx.reshape(a_reshaped, {a_rows, 1, a_cols, 1})
      |> Nx.multiply(Nx.reshape(b_reshaped, {1, b_rows, 1, b_cols}))
      |> Nx.reshape({a_rows * b_rows, a_cols * b_cols})

    if a_rank == 1 and b_rank == 1 do
      Nx.flatten(result)
    else
      result
    end
  end
end
