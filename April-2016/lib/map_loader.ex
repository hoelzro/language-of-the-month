import UnicodeData, only: [ is_letter?: 1 ]

defmodule ElixirRpg.MapLoader do
  defp map_char_type(char) do
    cond do
      char == " " -> :passable
      Enum.any?(String.graphemes("┌─│┐└┘"), fn(block_char) -> block_char == char end) -> :impassable
      char == "❌" -> :location
      is_letter? char -> :location
    end
  end

  defp process_char(_, {col_no, label}, {node_map, northward_labels, westward_label}) do
    case map_char_type label do
      :passable -> {node_map, northward_labels, westward_label}
      :impassable -> {node_map, Map.delete(northward_labels, col_no), nil}
      :location ->
        new_node = %MapNode{}

        if westward_label != nil do
          westward_node = Map.get(node_map, westward_label)
          westward_node = %{westward_node | east: label}
          node_map = Map.put(node_map, westward_label, westward_node)

          new_node = %{new_node | west: westward_label}
        end

        if Map.get(northward_labels, col_no) != nil do
          northward_label = Map.get(northward_labels, col_no)
          northward_node = Map.get(node_map, northward_label)
          northward_node = %{northward_node | south: label}
          node_map = Map.put(node_map, northward_label, northward_node)

          new_node = %{new_node | north: northward_label}
        end

        {Map.put(node_map, label, new_node), Map.put(northward_labels, col_no, label), label}
    end
  end

  defp process_line({row_no, line}, {node_map, northward_labels}) do
    num_chars = String.length(line)
    {node_map, northward_labels, _} = Enum.reduce(Enum.zip(0..num_chars - 1, String.graphemes(line)), {node_map, northward_labels, nil}, &process_char(row_no, &1, &2))
    {node_map, northward_labels}
  end

  defp lines_to_map(lines) do
    num_lines = length(lines)

    initial_state = { %{}, %{} }

    {node_map, _} = Enum.reduce(Enum.zip(0..num_lines-1, lines), initial_state, &process_line/2)

    node_map
  end

  defp describe_locations(map, lines) do
    Enum.reduce(lines, map, fn(line, map) ->
      [label | description] = String.split(line, ~r/\s+/, parts: 2)
      map_node = Map.get(map, label)
      if map_node == nil do
        map
      else
        map_node = %{ map_node | description: description }
        Map.put(map, label, map_node)
      end
    end)
  end

  def read_map_from_string(s) do
    lines = String.split(s, "\n")

    {text_art_lines, [_ | description_lines ]} = Enum.split_while(lines, &Regex.match?(~r/\S/, &1))

    map = lines_to_map(text_art_lines)

    unless Map.get(map, "❌") do
      raise "No starting position found"
    end

    map = describe_locations(map, description_lines)

    map
  end

  def read_map_from_file(filename) do
    contents = File.read!(filename)
    read_map_from_string(contents)
  end
end
