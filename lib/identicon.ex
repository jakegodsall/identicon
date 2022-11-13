defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_colour
    |> build_grid
  end

  @doc """
    Takes string input and returns `Identicon.Image{hex: hex}` struct where `hex` is the hexadecimal representation of the MD5 hash of the string.
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_colour(%Identicon.Image{hex: [red, green, blue | _tail]} = image) do
    %Identicon.Image{image | colour: {red, green, blue}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    hex
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(&mirror_row/1)
  end

  @doc """
    Takes an three element list and returns a five element symmetric list.any()

  ## Examples

        iex> Identicon.mirror_row([1, 2, 3])
        [1, 2, 3, 2, 1]

  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end
end
