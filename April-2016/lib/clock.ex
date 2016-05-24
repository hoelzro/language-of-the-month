defmodule ElixirRpg.Clock do
  defp format_time(minutes_into_day) do
    hours = div minutes_into_day, 60
    minutes = rem minutes_into_day, 60
    String.rjust(to_string(hours), 2, ?0) <> ":" <> String.rjust(to_string(minutes), 2, ?0)
  end

  def main() do
    loop = fn(loop, subscriptions, time_of_day, previous_time) ->
      current_time = System.system_time(:seconds)
      Enum.each(subscriptions, &send(&1, {:tick, format_time(time_of_day)}))
      if current_time != previous_time do
        time_of_day = rem(time_of_day + 6, 60 * 24)
      end

      receive do
        {:subscribe, subscriber} ->
          loop.(loop, [ subscriber | subscriptions ], time_of_day, current_time)
        {:what_time_is_it, requestor} ->
          send(requestor, {:tick, format_time(time_of_day)})
          loop.(loop, subscriptions, time_of_day, current_time)
      after
        100 -> loop.(loop, subscriptions, time_of_day, current_time)
      end
    end

    loop.(loop, [], 0, System.system_time(:seconds))
  end
end
