defmodule Castor.Examples.CoreTypesRequired do
  @derive {Castor.Def,
           [
             test_attr_float: [type: :float, required: true],
             test_attr_number: [type: :float, required: true],
             test_attr_atom: [type: :float, required: true],
             test_attr_boolean: [type: :float, required: true],
             test_attr_binary: [type: :float, required: true],
             test_attr_function: [type: :float, required: true],
             test_attr_list: [type: :float, required: true],
             test_attr_tuple: [type: :float, required: true],
           ]}

  defstruct [
    :test_attr_float,
    :test_attr_number,
    :test_attr_atom,
    :test_attr_boolean,
    :test_attr_binary,
    :test_attr_function,
    :test_attr_list,
    :test_attr_tuple
  ]

  @type t :: %__MODULE__{
          test_attr_float: :float,
          test_attr_number: :number,
          test_attr_atom: :atom,
          test_attr_boolean: :boolean,
          test_attr_binary: String.t(),
          test_attr_function: :function,
          test_attr_list: :list,
          test_attr_tuple: :tuple
        }
end
