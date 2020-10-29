defmodule Castor.Digest do
  @spec extract_typespec_to_typedef(atom | binary) ::
          {:no_typespec}
          | {:error, [{:error, any}]}
          | {:ok, [{:atom, [{:type, :atom}]}]}
  def extract_typespec_to_typedef(module) do
    case Code.Typespec.fetch_types(module) do
      {:ok,
       [
         type: {:t, {:type, _, :map, typespec_list}, _}
       ]} ->
        digest_typespec_list(typespec_list)
        |> validate_typedef()

      {:ok, []} ->
        {:no_typespec}

      other ->
        {:error, other}
    end
  end

  @spec validate_typedef(any) ::
          {:error, [{:error, any}]} | {:ok, [{:atom, [{:type, :atom}]}]}
  def validate_typedef(typedef) do
    errors =
      typedef
      |> Enum.filter(fn t ->
        case t do
          {:error, _} ->
            true

          _ ->
            false
        end
      end)

    if Enum.count(errors) > 0 do
      {:error, errors}
    else
      {:ok, typedef}
    end
  end

  @spec digest_typespec_list(any) :: [{:atom, [{:type, :atom}, ...]} | {:error, any}]
  def digest_typespec_list(typespec_list) do
    typespec_list
    |> Enum.map(&digest_typespec_attr/1)
    |> Enum.filter(fn t -> t != nil end)
  end

  @spec digest_typespec_attr(any) :: nil | {:atom, [{:type, :atom}, ...]} | {:error, any}
  def digest_typespec_attr(typespec_attr) do
    case typespec_attr do
      {:type, _num, :map_field_exact,
       [{:atom, _zero_1, typespec_name}, {:atom, _zero_2, typespec_type}]} ->
        create_typedef(typespec_name, typespec_type)

      {:type, _, :map_field_exact,
       [
         {:atom, _, typespec_name},
         {:remote_type, _, [{:atom, _, typespec_type}, {:atom, _, :t}, []]}
       ]} ->
        create_typedef(typespec_name, typespec_type)

      other ->
        {:error, other}
    end
  end

  @spec create_typedef(:atom, :atom) :: nil | {:atom, [{:type, :atom}]}
  def create_typedef(typespec_name, typespec_type) do
    case typespec_name do
      :__struct__ ->
        nil

      _ ->
        {typespec_name, [type: map_types(typespec_type)]}
    end
  end

  @spec map_types(:atom) :: :atom
  def map_types(String), do: :binary
  def map_types(type), do: type
end
