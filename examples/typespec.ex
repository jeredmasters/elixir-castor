defmodule Castor.Examples.Typespec do
  defstruct [
    :test_attr_float,
    :test_attr_number,
    :test_attr_atom,
    :test_attr_boolean,
    :test_attr_binary,
    :test_attr_string,
    :test_attr_function,
    :test_attr_list,
    :test_attr_tuple
  ]

  @type t :: %__MODULE__{
          test_attr_float: :float,
          test_attr_number: :number,
          test_attr_atom: :atom,
          test_attr_boolean: :boolean,
          test_attr_binary: :binary,
          test_attr_string: String.t(),
          test_attr_function: :function,
          test_attr_list: :list,
          test_attr_tuple: :tuple
        }
end
