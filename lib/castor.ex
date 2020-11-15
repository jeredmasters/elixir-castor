defprotocol Castor.Def do
  @fallback_to_any true
  def validation(arg)
end

defimpl Castor.Def, for: Any do
  defmacro __deriving__(module, _struct, options) do
    quote do
      defimpl Castor.Def, for: unquote(module) do
        def validation(_arg) do
          {:ok, unquote(options)}
        end
      end
    end
  end

  def validation(arg) do
    case Castor.Digest.extract_typespec_to_typedef(arg.__struct__) do
      {:ok, typedef} ->
        {:ok, typedef}

      {:no_typespec} ->
        {:not_set}

      {:error, _error} ->
        {:not_set}
    end
  end
end

defmodule Castor do
  @core_types [
    :float,
    :number,
    :atom,
    :boolean,
    :binary,
    :function,
    :list,
    :tuple
  ]

  def from_json(struct_type, json) do
    case Jason.decode(json) do
      {:ok, string_map} ->
        from_string_map(struct_type, string_map)

      {:error, error} ->
        {:error, error}
    end
  end

  def from_string_map(struct_type, attrs) do
    s = struct(struct_type)

    result =
      case Castor.Def.validation(s) do
        {:not_set} ->
          Enum.reduce(Map.to_list(s), s, fn {k, _}, acc ->
            case Map.fetch(attrs, Atom.to_string(k)) do
              {:ok, v} -> Map.put(acc, k, v)
              :error -> acc
            end
          end)

        {:ok, types} ->
          Enum.reduce_while(Map.to_list(s), s, fn {attr_name, _}, acc ->
            typedef = normalise_typedef(types[attr_name])

            case Map.get(attrs, Atom.to_string(attr_name), nil) do
              nil ->
                case typedef[:required] do
                  true ->
                    {:halt, {:error, {:attr_required, %{required: attr_name}}}}

                  _ ->
                    {:cont, acc}
                end

              raw_value ->
                case validate_and_resolve(attr_name, raw_value, typedef) do
                  {:ok, child_struct} ->
                    {:cont, Map.put(acc, attr_name, child_struct)}

                  {:valid, value} ->
                    {:cont, Map.put(acc, attr_name, value)}

                  {:invalid, expected_type, received_type} ->
                    {:halt,
                     {:error,
                      {:invalid_type,
                       %{
                         attr_name: attr_name,
                         raw_value: raw_value,
                         expected_type: expected_type,
                         received_type: received_type
                       }}}}
                end
            end
          end)
      end

    case result do
      {:error, e} -> {:error, e}
      val -> {:ok, val}
    end
  end

  defp validate_and_resolve(attr_name, value, typedef) do
    case attr_name do
      :__struct__ ->
        {:valid, value}

      nil ->
        case typedef[:required] do
          true ->
            {:attr_required, %{required: attr_name}}

          _ ->
            nil
        end

      _ ->
        expected_type = typedef[:type]

        if Enum.member?(@core_types, expected_type) do
          received_type = typeof(value)

          if received_type == expected_type do
            {:valid, value}
          else
            {:invalid, expected_type, received_type}
          end
        else
          from_string_map(expected_type, value)
        end
    end
  end

  defp normalise_typedef(typedef) when is_atom(typedef) do
    [type: typedef, required: false]
  end

  defp normalise_typedef(typedef) when is_list(typedef) do
    [
      type: Keyword.get(typedef, :type),
      required: Keyword.get(typedef, :required, false)
    ]
  end

  @spec typeof(any) ::
          :atom | :binary | :boolean | :float | :function | :list | :number | :tuple | :unknown
  defp typeof(self) do
    cond do
      is_float(self) -> :float
      is_number(self) -> :number
      is_atom(self) -> :atom
      is_boolean(self) -> :boolean
      is_binary(self) -> :binary
      is_function(self) -> :function
      is_list(self) -> :list
      is_tuple(self) -> :tuple
      true -> :unknown
    end
  end
end
