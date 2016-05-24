import ElixirRpg.Npc, only: [ create_npc: 2 ]
import Oop
import RpgHelper

defmodule ElixirRpg.NpcManager do
  def get_npcs(this) do
    call_method(this, :get_npcs)
  end

  def is_present?(this, npc) do
    call_method(this, :is_present, {npc})
  end

  def talk_to(this, npc) do
    call_method(this, :talk_to, {npc})
  end

  defp get_npcs_impl(location, npcs) do
    send(location, {:get_current_location, self()})
    label = receive do
      {:location, label} -> label
    end

    Enum.filter_map npcs, fn(npc) ->
      send(npc, {:where_are_you, self()})

      current_location = receive do
        {:location, label} -> label
      end

      current_location == label
    end, fn(npc) ->
      send(npc, {:whats_your_name, self()})
      receive do
        {:name, name} -> name
      end
    end
  end

  defp is_present_impl(location, npcs, npc) do
    npcs = get_npcs_impl(location, npcs)
    Enum.member? npcs, npc
  end

  defp talk_to_impl(_, npcs, npc_name) do
    [npc | []] = Enum.filter npcs, fn(npc) ->
      send(npc, {:whats_your_name, self()})
      receive do
        {:name, name} -> name == npc_name
      end
    end
    send(npc, {:converse, self()})
    receive do
      {:statement, statement} -> statement
    end
  end

  defp broadcast(pids) do
    receive_forever do
      msg -> Enum.each pids, &send(&1, msg)
    end
  end

  def main(clock, location) do
    npcs = [
      create_npc(ElixirRpg.Npcs.Alice, self()),
      create_npc(ElixirRpg.Npcs.Bob, self()),
      create_npc(ElixirRpg.Npcs.Carol, self()),
    ]

    spawn(fn() ->
      send(clock, {:subscribe, self()})
      broadcast(npcs)
    end)

    receive_forever do
      {:get_npcs, requestor} ->
        send(requestor, {:get_npcs, :response, get_npcs_impl(location, npcs)})
      {:is_present, npc, requestor} ->
        send(requestor, {:is_present, :response, is_present_impl(location, npcs, npc)})
      {:talk_to, npc, requestor} ->
        send(requestor, {:talk_to, :response, talk_to_impl(location, npcs, npc)})
      {:update_location, _, _} -> nil
      msg -> raise inspect(msg)
    end
  end
end
