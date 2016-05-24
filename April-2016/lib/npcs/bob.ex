import RpgHelper

defmodule ElixirRpg.Npcs.Bob do
  @behaviour ElixirRpg.NpcBehavior

  def name() do
    "Bob"
  end

  def where_are_you(time) do
    cond do
      between? time, "09:00", "16:30" -> "C"
      between? time, "16:31", "16:55" -> "A"
      between? time, "16:56", "22:00" -> "D"
      true                             -> "_"
    end
  end

  def converse(_, location) do
    case location do
      "A" -> "I'm just here to buy an ax from Alice."
      "C" -> "Welcome to Bob's Barrels!"
      "D" -> "Greetings!  If you're looking for a barrel, we open at 09:00"
      _   -> "Zzzzzzz"
    end
  end
end
