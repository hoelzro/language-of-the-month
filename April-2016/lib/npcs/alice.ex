import RpgHelper

defmodule ElixirRpg.Npcs.Alice do
  @behaviour ElixirRpg.NpcBehavior

  def name() do
    "Alice"
  end

  def where_are_you(time) do
    cond do
      between? time, "09:00", "17:00" -> "A"
      between? time, "17:01", "23:59" -> "B"
      true                            -> "_"
    end
  end

  def converse(_, location) do
    case location do
      "A" -> "Hi, welcome to Alice's Axes! How can I help you?"
      "B" -> "Hello, make yourself at home!"
      _   -> "Zzzzzzz"
    end
  end
end
