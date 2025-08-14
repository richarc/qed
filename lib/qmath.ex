defmodule QED.Qmath do
  import Nx.Defn

  @doc """
  Computes the Kronecker product of two vectors `u` and `v`.
  Both `u` and `v` should be Nx tensors of shape {m} and {n} respectively.
  Returns a tensor of shape {m * n}.
  We provide a defualt value for the second argument for the case when only one value is provided.
  """
  defn kronecker_product(u, v \\ Nx.tensor([1])) do
    {m} = Nx.shape(u)
    {n} = Nx.shape(v)

    # Reshape u to {m, 1} and v to {1, n} so Nx multiplies each element of u by all of v
    u_expanded = Nx.reshape(u, {m, 1})
    v_expanded = Nx.reshape(v, {1, n})

    # Multiply then flatten back to a vector
    Nx.flatten(Nx.multiply(u_expanded, v_expanded))
  end
end
