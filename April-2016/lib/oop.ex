defmodule Oop do
  def call_method(this, method_name, arguments \\ {}) do
    full_arguments = Tuple.append(arguments, self())
    full_arguments = Tuple.insert_at(full_arguments, 0, method_name)
    send(this, full_arguments)

    receive do
      {^method_name, :response, value} -> value
    end
  end
end
