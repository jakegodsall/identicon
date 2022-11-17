defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Takes string input and returns `Identicon.Image{hex: hex}` struct where `hex` is the hexadecimal representation of the MD5 hash of the string.

    ## Examples

          iex> Identicon.hash_input("test")
          %Identicon.Image{
            hex: [9, 143, 107, 205, 70, 33, 211, 115, 202, 222, 78, 131, 38, 39, 180, 246],
            color: nil,
            grid: nil,
            pixel_map: nil}

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Extracts the first three values from `%Identicon.Image{hex: hex}` and adds as `%Identicon.Image{color: color}`.

  ## Examples

        iex> test = %Identicon.Image{hex: [1, 2, 3, 4, 5]}
        iex> Identicon.pick_color(test)
        %Identicon.Image{
          hex: [1, 2, 3, 4, 5],
          color: {1, 2, 3},
          grid: nil,
          pixel_map: nil
        }

  """
  def pick_color(%Identicon.Image{hex: [red, green, blue | _tail]} = image) do
    %Identicon.Image{image | color: {red, green, blue}}
  end


  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
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

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn(x) ->
      rem(elem(x, 0), 2) != 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_value, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill_color = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill_color)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
