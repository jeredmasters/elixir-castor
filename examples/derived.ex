defmodule Castor.Examples.Derived do
  @derive {Castor.Def,
           [
             test_attr_float: [type: :float, required: true],
             test_attr_binary: [type: :binary, required: false],
           ]}

  defstruct [
    :test_attr_float,
    :test_attr_binary
  ]

  @type t :: %__MODULE__{
          test_attr_float: :float,
          test_attr_binary: :binary
        }
end
