defmodule Castor.Examples.Recursive do
  @derive {Castor.Def,
  [
    child: [type: Castor.Examples.Recursive.Child, required: true],
  ]}

  defstruct [
    :child
  ]

end


defmodule Castor.Examples.Recursive.Child do
  @derive {Castor.Def,
            [
              name: [type: :binary, required: true],
              age: :number
            ]}

  defstruct [
    :name,
    :age
  ]

end
