# Castor

Cast maps and keywords into defined structs. Validate types and requirements.

### Implicit Struct Types

In the most basic version this library will detect the attributes on a vanilla struct.

```elixir
defmodule Castor.Examples.Implicit do
  defstruct [
    :test_attr,
  ]
end

iex> Castor.from_string_map(Castor.Examples.Implicit, %{"test_attr" => "example"})
{:ok, %Castor.Examples.Implicit{test_attr: "example"}}
```

### Typespec Struct Types

```elixir
defmodule Castor.Examples.Typespec do
  defstruct [
    :test_attr_float
  ]

  @type t :: %__MODULE__{
          test_attr_float: :float
        }
end

iex> Castor.from_string_map(Castor.Examples.Typespec, %{"test_attr_float" => 1.11})
{:ok,
 %Castor.Examples.Typespec{
   test_attr_float: 1.11,
 }}

iex> Castor.from_string_map(Castor.Examples.Typespec, %{"test_attr_float" => "example"})
{:error,
 {:invalid_type,
  %{
    attr_name: :test_attr_float,
    expected_type: :float,
    raw_value: "example",
    received_type: :binary
  }}}
```

### Derived Struct Types

Castor implements it's own compile time protocol for defining types.
If both @derive and @type are present it will prefer @derive

```elixir
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


iex(8)> Castor.from_string_map(Castor.Examples.Derived, %{"test_attr_float" => 1.11})
{:ok,
 %Castor.Examples.Derived{
   test_attr_binary: nil,
   test_attr_float: 1.11
 }}
iex(9)> Castor.from_string_map(Castor.Examples.Derived, %{"test_attr_float" => 1.11, "test_attr_binary" => "test"})
{:ok,
 %Castor.Examples.Derived{
   test_attr_binary: "test",
   test_attr_float: 1.11
 }}

iex(11)> Castor.from_string_map(Castor.Examples.Derived, %{"test_attr_binary" => "test"})
{:error, {:attr_required, %{required: :test_attr_float}}}
```

### Recursive Structs

```elixir
defmodule Castor.Examples.Recursive do
  @derive {Castor.Def,
  [
    child: [type: Castor.Examples.Recursive.Child, required: true],
  ]}

  defstruct [
    :child,
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

iex> Castor.from_string_map(Castor.Examples.Recursive, %{"child" => %{"name" => "Foo Bar", "age" => 15}})
{:ok,
 %Castor.Examples.Recursive{
   child: %Castor.Examples.Recursive.Child{age: 15, name: "Foo Bar"}
 }}
```
