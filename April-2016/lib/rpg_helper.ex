defmodule RpgHelper do
  defmacro forever(block) do
    quote do
      f = fn(next) ->
        unquote(block)
        next.(next)
      end
      f.(f)
    end
  end

  defmacro receive_forever(block) do
    quote do
      forever do
        receive unquote(block)
      end
    end
  end

  def between?(value, low, high) do
    value >= low && value <= high
  end

  def english_join(strings) do
    case strings do
      [] -> ""
      [s | []] -> s
      [s | [s2 | []]] -> s <> " and " <> s2
      multiple_strings ->
        [final_string | first_strings] = Enum.reverse(multiple_strings)
        first_strings = Enum.reverse(first_strings)

        Enum.join(first_strings, ", ") <> ", and " <> final_string
    end
  end
end
