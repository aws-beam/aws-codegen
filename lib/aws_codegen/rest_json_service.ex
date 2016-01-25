defmodule AWS.CodeGen.RestJSONService do
  alias AWS.CodeGen.Docstring

  defmodule Service do
    defstruct abbreviation: nil,
              actions: [],
              docstring: nil,
              signing_name: nil,
              endpoint_prefix: nil,
              json_version: nil,
              module_name: nil,
              protocol: nil,
              target_prefix: nil
  end

  defmodule Action do
    defstruct arity: nil,
              docstring: nil,
              method: nil,
              request_uri: nil,
              success_status_code: nil,
              function_name: nil,
              name: nil,
              url_parameters: [],
              request_header_parameters: [],
              response_header_parameters: []

    def method(:elixir, action) do
      ":#{action.method |> String.downcase |> String.to_atom}"
    end

    def method(:erlang, action) do
      "#{action.method |> String.downcase |> String.to_atom}"
    end

    def url(:elixir, action) do
      Enum.reduce(action.url_parameters, action.request_uri,
        fn(parameter, acc) ->
          name = Enum.join([~S(#{), "URI.encode(", parameter.code_name, ")", ~S(})])
          String.replace(acc, "{#{parameter.name}}", "#{name}")
        end) |>
      # FIXME(jkakar) This is only here because the invoke-async method
      # defined for the Lambda API has an apparentyl spurious trailing slash
      # in the JSON spec.
      String.rstrip(?/)
    end

    def url(:erlang, _action) do
      # Enum.reduce(action.url_parameters, action.request_uri,
      #   fn(parameter, acc) ->
      #     [head, tail] = String.split(
      #   end)

      # url = Enum.reduce(action.url_parameters, action.request_uri,
      #   fn(parameter, acc) ->
      #     name = Enum.join([~S(#{), "URI.encode(", parameter.code_name, ")", ~S(})])
      #     String.replace(acc, "{#{parameter.name}}", "#{name}")
      #   end)
      ""
    end
  end

  defmodule Parameter do
    defstruct code_name: nil,
              name: nil
  end

  @doc """
  Load JSON API service and documentation specifications from the
  `api_spec_path` and `doc_spec_path` files and convert them into a context
  that can be used to generate code for an AWS service.  `language` must be
  `:elixir` or `:erlang`.
  """
  def load_context(language, module_name, api_spec_path, doc_spec_path) do
    api_spec = File.read!(api_spec_path) |> Poison.Parser.parse!
    doc_spec = File.read!(doc_spec_path) |> Poison.Parser.parse!
    build_context(language, module_name, api_spec, doc_spec)
  end

  @doc """
  Render a code template.
  """
  def render(context, template_path) do
    EEx.eval_file(template_path, [context: context])
  end

  @doc """
  Render function parameter, if any, in a way that can be inserted directly
  into the code template.
  """
  def function_parameters(:elixir, action) do
    Enum.join([join_parameters(:elixir, action.url_parameters, :undefined),
               join_header_parameters(:elixir, action)])
  end

  def function_parameters(:erlang, action) do
    Enum.join([join_parameters(:erlang, action.url_parameters, :undefined),
               join_header_parameters(:erlang, action)])
  end

  defp join_header_parameters(language, action) do
    if action.method == "GET" do
      join_parameters(language, action.request_header_parameters, nil)
    else
      ""
    end
  end

  defp join_parameters(:elixir, parameters, default) do
    Enum.join(Enum.map(parameters,
          fn(parameter) ->
            if default == :undefined do
              ", #{parameter.code_name}"
            else
              ", #{parameter.code_name} \\\\ #{inspect(default)}"
            end
          end))
  end

  defp join_parameters(:erlang, parameters, _default) do
    Enum.join(Enum.map(parameters,
          fn(parameter) ->
            {first, remainder} = String.split_at(parameter.code_name, 1)
            ", #{String.capitalize(first) <> remainder}"
          end))
  end

  defp build_context(language, module_name, api_spec, doc_spec) do
    actions = collect_actions(language, api_spec, doc_spec)
    signing_name = case api_spec["metadata"]["signingName"] do
     :nil -> api_spec["metadata"]["endpointPrefix"];
     sn   -> sn
    end
    %Service{actions: actions,
             docstring: Docstring.format(language, doc_spec["service"]),
             signing_name: signing_name,
             endpoint_prefix: api_spec["metadata"]["endpointPrefix"],
             json_version: api_spec["metadata"]["jsonVersion"],
             module_name: module_name,
             protocol: api_spec["metadata"]["json"],
             target_prefix: api_spec["metadata"]["targetPrefix"]}
  end

  defp collect_actions(language, api_spec, doc_spec) do
    Enum.map(api_spec["operations"], fn({operation, _metadata}) ->
      url_parameters = collect_url_parameters(language, api_spec, operation)
      %Action{arity: 3 + length(url_parameters),
              docstring: Docstring.format(language,
                                          doc_spec["operations"][operation]),
              method: api_spec["operations"][operation]["http"]["method"],
              request_uri: api_spec["operations"][operation]["http"]["requestUri"],
              success_status_code: api_spec["operations"][operation]["http"]["responseCode"],
              function_name: AWS.CodeGen.Name.to_snake_case(operation),
              name: operation,
              url_parameters: url_parameters,
              request_header_parameters: collect_request_header_parameters(language, api_spec, operation),
              response_header_parameters: collect_response_header_parameters(language, api_spec, operation)}
    end)
    |> Enum.sort(fn(a, b) -> a.function_name < b.function_name end)
  end

  defp collect_url_parameters(language, api_spec, operation) do
    shape_name = api_spec["operations"][operation]["input"]["shape"]
    shape = api_spec["shapes"][shape_name]
    Enum.filter_map(shape["members"], filter_fn("uri"), build_parameter_fn(language))
  end

  defp collect_request_header_parameters(language, api_spec, operation) do
    collect_header_parameters(language, api_spec, operation, "input")
  end

  defp collect_response_header_parameters(language, api_spec, operation) do
    collect_header_parameters(language, api_spec, operation, "output")
  end

  defp collect_header_parameters(language, api_spec, operation, data_type) do
    shape_name = api_spec["operations"][operation][data_type]["shape"]
    shape = api_spec["shapes"][shape_name]
    case shape do
      nil -> []
      ^shape -> Enum.filter_map(shape["members"], filter_fn("header"),
                                build_parameter_fn(language))
    end
  end

  defp filter_fn(location) do
    fn({_name, member_spec}) ->
      case member_spec["location"] do
        ^location -> true
        _ -> false
      end
    end
  end

  defp build_parameter_fn(language) do
    case language do
      :elixir -> &build_elixir_parameter/1
      :erlang -> &build_erlang_parameter/1
    end
  end

  defp build_elixir_parameter({name, _}) do
    %Parameter{code_name: AWS.CodeGen.Name.to_snake_case(name),
               name: name}
  end

  defp build_erlang_parameter({name, _}) do
    %Parameter{code_name: name,
               name: name}
  end
end
