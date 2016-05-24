defmodule ElixirRpg.NpcBehavior do
  @callback name() :: String.t
  @callback where_are_you(String.t) :: String.t
  @callback converse(String.t, String.t) :: String.t
end

defmodule ElixirRpg.Npc do
  def create_npc(npc_behavior, manager) do
    spawn(fn() ->
      loop = fn(loop, current_time, current_location) ->
        receive do
          {:whats_your_name, requestor} ->
            send(requestor, {:name, npc_behavior.name()})
            loop.(loop, current_time, current_location)
          {:tick, time} ->
            new_location = npc_behavior.where_are_you(time)
            send(manager, {:update_location, npc_behavior.name(), new_location})
            loop.(loop, current_time, new_location)
          {:converse, requestor} ->
            send(requestor, {:statement, npc_behavior.converse(current_time, current_location)})
            loop.(loop, current_time, current_location)
          {:where_are_you, requestor} ->
            send(requestor, {:location, current_location})
            loop.(loop, current_time, current_location)
        end
        raise "I should never get here!"
      end

      receive do
        {:tick, time} -> loop.(loop, time, npc_behavior.where_are_you(time))
      end
    end)
  end
end
