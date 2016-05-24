import Oop

defmodule MapNode do
  defstruct north: nil, south: nil, east: nil, west: nil, description: nil
end

defmodule ElixirRpg.LocationManager do
  def can_go?(location, direction) do
    call_method(location, :can_go, {direction})
  end

  def move(location, direction) do
    call_method(location, :move, {direction})
  end

  def get_exits(location) do
    call_method(location, :get_exits)
  end

  def describe_current_location(location) do
    call_method(location, :get_description)
  end

  defp advance(map, label, direction) do
    Map.get(Map.get(map, label), direction)
  end

  defp direction_available?(map, label, direction) do
    Map.get(Map.get(map, label), direction) != nil
  end

  def valid_direction?(direction) do
    direction == :north || direction == :south || direction == :east || direction == :west
  end

  def main(map) do
    current_label = "❌"

    loop = fn(loop, current_label) ->
      receive do
        {:can_go, direction, requestor} -> send(requestor, {:can_go, :response, direction_available?(map, current_label, direction)}); loop.(loop, current_label)
        {:move, direction, requestor} ->
          new_position = advance(map, current_label, direction)
          send(requestor, {:move, :response, true})
          loop.(loop, new_position)
        {:get_exits, requestor} ->
          send(requestor,
          {:get_exits, :response, for(direction <- [:north, :south, :east, :west],
              direction_available?(map, current_label, direction),
            do: Atom.to_string(direction))})
          loop.(loop, current_label)
        {:get_description, requestor} ->
          current_location = Map.get(map, current_label)
          description = current_location.description

          send(requestor, {:get_description, :response, description})
          loop.(loop, current_label)
        {:get_current_location, requestor} ->
          send(requestor, {:location, current_label})
          loop.(loop, current_label)
      end
      raise "I should never end!"
    end

    loop.(loop, current_label)
  end
end
