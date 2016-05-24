import RpgHelper

import ElixirRpg.LocationManager, only: [can_go?: 2, move: 2, describe_current_location: 1, get_exits: 1, valid_direction?: 1]
import ElixirRpg.NpcManager, only: [is_present?: 2, get_npcs: 1, talk_to: 2]

defmodule ElixirRpg.Evaulate do
  defp help_message, do: '''
  go <direction>		- Travel in the given direction.
  help			- Shows this help message.
  look			- Look at your surroundings.
  talk to <person>	- Talk to <person>.
  what time is it       - Find out the current time
  '''

  defp describe_location(location, printer) do
    send(printer, describe_current_location(location))
  end

  defp describe_people(npc_mgr, printer) do
    npcs = get_npcs(npc_mgr)
    description = case npcs do
      [] -> nil
      [npc | []] -> npc <> " is here"
      _ -> english_join(npcs) <> " are here"
    end
    if description != nil do
      send(printer, description)
    end
  end

  defp describe_exits(location, printer) do
    exits = get_exits(location)
    send(printer, "There are exits to the " <> english_join(exits))
  end

  defp evaluate_command(:look, location, npc_mgr, _, printer) do
    describe_location(location, printer)
    describe_people(npc_mgr, printer)
    describe_exits(location, printer)
  end

  defp evaluate_command(:what_time_is_it, _, _, clock, printer) do
    send(clock, {:what_time_is_it, self()})
    time = receive do
      {:tick, time} -> time
    end
    send(printer, "It's " <> time)
  end

  defp evaluate_command(:go, direction, location, npc_mgr, clock, printer) do
    if valid_direction? direction do
      if can_go? location, direction do
        move location, direction
        evaluate_command(:look, location, npc_mgr, clock, printer)
      else
        send(printer, "You can't move in that direction.")
      end
    else
      send(printer, to_string(direction) <> " is not a valid direction.")
    end
  end

  defp evaluate_command(:talk_to, npc_name, _, npc_mgr, _, printer) do
    if is_present? npc_mgr, npc_name do
      statement = talk_to(npc_mgr, npc_name)
      send(printer, npc_name <> ": " <> statement)
    else
      send(printer, npc_name <> " isn't here")
    end
  end

  def main(location, npc_mgr, clock) do
    receive_forever do
      {:help, destination} -> send(destination, help_message)
      {command, destination} -> evaluate_command command, location, npc_mgr, clock, destination
      {command, arg, destination} -> evaluate_command command, arg, location, npc_mgr, clock, destination
    end
  end
end
