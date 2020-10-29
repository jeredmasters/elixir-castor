defmodule CastorTest do
  use ExUnit.Case
  doctest Castor

  describe "Typespec" do
    test "Optional" do
      {:ok, result} =
        Castor.from_string_map(Castor.Examples.Typespec, %{
          "test_attr_float" => 11.11,
          "test_attr_binary" => "TEST STRING"
        })

      assert result.test_attr_float == 11.11

      assert result.test_attr_number == nil
      assert result.test_attr_atom == nil
      assert result.test_attr_boolean == nil
      assert result.test_attr_binary == "TEST STRING"
      assert result.test_attr_function == nil
      assert result.test_attr_list == nil
      assert result.test_attr_tuple == nil
    end

    test "Bad type" do
      {:error, {_e_type, error}} =
        Castor.from_string_map(Castor.Examples.Typespec, %{
          "test_attr_float" => "TEST STRING"
        })

      assert error.attr_name == :test_attr_float
    end
  end

  describe "CoreTypesOptional" do
    test "Casts" do
      {:ok, result} =
        Castor.from_string_map(Castor.Examples.CoreTypesOptional, %{
          "test_attr_float" => 5.55
        })

      assert result.test_attr_float == 5.55

      assert result.test_attr_number == nil
      assert result.test_attr_atom == nil
      assert result.test_attr_boolean == nil
      assert result.test_attr_binary == nil
      assert result.test_attr_function == nil
      assert result.test_attr_list == nil
      assert result.test_attr_tuple == nil
    end
  end

  describe "CoreTypesRequired" do
    test "Casts" do
      {:error, {_e_type, error}} =
        Castor.from_string_map(Castor.Examples.CoreTypesRequired, %{
          "test_attr_float" => 5.55
        })

      assert error.required == :test_attr_atom
    end
  end

  describe "Recursive" do
    test "Casts" do
      {:ok, result} =
        Castor.from_string_map(Castor.Examples.Recursive, %{
          "child" => %{
            "name" => "Foo bar",
            "age" => 10
          }
        })

      assert result.child.name == "Foo bar"
    end
  end
end
