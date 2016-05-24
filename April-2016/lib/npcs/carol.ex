import RpgHelper

defmodule ElixirRpg.Npcs.Carol do
  @behaviour ElixirRpg.NpcBehavior

  def name() do
    "Carol"
  end

  def where_are_you(time) do
    cond do
      between? time, "09:30", "10:30" -> "A"
      between? time, "10:31", "12:30" -> "E"
      between? time, "12:31", "16:00" -> "F"
      between? time, "16:01", "17:00" -> "A"
      true                            -> "_"
    end
  end

  def converse(time, location) do
    case location do
      "A" ->
        cond do
          between? time, "09:30", "10:30" -> "I just thought I'd drop by and pay my friend Alice a visit."
          between? time, "16:01", "16:30" -> "I remembered I needed to stop by Alice's and buy some axes for my sales charts!"
          true -> "I remembered I needed to stop by Alice's and buy some axes for my sales charts!  It also doesn't hurt to check out my competition while he's here. ;)"
        end
      "E" -> "I thought I would do some shopping while the produce is fresh."
      "F" -> "Welcome to Carol's Barrels!"
      _   -> "Zzzzzzz"
    end
  end
end
