import RpgHelper

import ElixirRpg.MapLoader, only: [read_map_from_file: 1]
require ElixirRpg.Evaulate

defmodule ElixirRpg do
  defp reader(destination, printer) do
    Enum.each IO.stream(:stdio, :line), &send(destination, {:line, &1, printer})
  end

  defp parse_command(line) do
    stripped_line = String.strip(line)

    case String.split(String.downcase(stripped_line), " ", parts: 4) do
      ["help"]                     -> {:ok, :help}
      ["look"]                     -> {:ok, :look}
      ["go", direction]            -> {:ok, :go, String.to_atom(direction)}
      ["talk", "to", person]       -> {:ok, :talk_to, String.capitalize(person)}
      ["what", "time", "is", "it"] -> {:ok, :what_time_is_it}

      _ -> {:error, "Unable to parse '#{stripped_line}'"}
    end
  end

  defp parser(evaluator) do
    receive_forever do
      {:line, line, printer} ->
        case parse_command line do
          {:error, _}  -> send(printer, "Sorry, I don't understand.")
          {:ok, command} -> send(evaluator, {command, printer})
          {:ok, command, arg} -> send(evaluator, {command, arg, printer})
        end
    end
  end

  defp printer do
    receive_forever do
      line -> IO.puts(line)
    end
  end

  def main do
    map = read_map_from_file("map.txt")
    clock = spawn(fn() -> ElixirRpg.Clock.main() end)
    location_manager_proc = spawn(fn() -> ElixirRpg.LocationManager.main(map) end)
    npc_manager_proc = spawn(fn() -> ElixirRpg.NpcManager.main(clock, location_manager_proc) end)
    evaluator_proc = spawn(fn() -> ElixirRpg.Evaulate.main(location_manager_proc, npc_manager_proc, clock) end)
    parser_proc = spawn(fn() -> parser(evaluator_proc) end)
    printer_proc = spawn(&printer/0)
    send(evaluator_proc, {:look, printer_proc})
    reader parser_proc, printer_proc
  end
end
