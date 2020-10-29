defmodule Castor.DigestTest do
  use ExUnit.Case
  doctest Castor

  test "Typespec" do
    {:ok, typedef} = Castor.Digest.extract_typespec_to_typedef(Castor.Examples.Typespec)

    assert typedef[:test_attr_atom] == [type: :atom]
    assert typedef[:test_attr_binary] == [type: :binary]
    assert typedef[:test_attr_boolean] == [type: :boolean]
    assert typedef[:test_attr_float] == [type: :float]
    assert typedef[:test_attr_function] == [type: :function]
    assert typedef[:test_attr_list] == [type: :list]
    assert typedef[:test_attr_number] == [type: :number]
    assert typedef[:test_attr_string] == [type: :binary]
    assert typedef[:test_attr_tuple] == [type: :tuple]
  end

  test "Implicit" do
    result = Castor.Digest.extract_typespec_to_typedef(Castor.Examples.Implicit)
    assert result == {:no_typespec}
  end
end
