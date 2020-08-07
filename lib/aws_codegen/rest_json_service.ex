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
              target_prefix: nil,
              options: []
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
              response_header_parameters: [],
              language: nil

    def method(action) do
      result = action.method |> String.downcase |> String.to_atom
      "#{if action.language == :elixir, do: ":", else: ""}#{result}"
    end

    def url_path(action) do
      Enum.reduce(action.url_parameters, action.request_uri,
        fn(parameter, acc) ->
          name = if action.language == :elixir do
              Enum.join([~S(#{), "URI.encode(", parameter.code_name, ")", ~S(})])
            else
              Enum.join(["\", http_uri:encode(", parameter.code_name, "), \""])
            end
          # Some url parameters have a trailing "+" indicating they are
          # multi-segment. This regex takes that into account.
          {:ok, re} = Regex.compile("{#{parameter.location_name}\\+?}")
          String.replace(acc, re, name)
        end) |>
        # FIXME(jkakar) This is only here because the invoke-async method
        # defined for the Lambda API has an apparently spurious trailing slash
        # in the JSON spec.
        String.trim_trailing("/")
    end
  end

  defmodule Parameter do
    defstruct code_name: nil,
              name: nil,
              location_name: nil
  end

  @doc """
  Load JSON API service and documentation specifications from the
  `api_spec_path` and `doc_spec_path` files and convert them into a context
  that can be used to generate code for an AWS service.  `language` must be
  `:elixir` or `:erlang`.
  """
  def load_context(language, module_name, api_spec_path, doc_spec_path, options) do
    api_spec = File.read!(api_spec_path) |> Poison.Parser.parse!(%{})
    doc_spec = File.read!(doc_spec_path) |> Poison.Parser.parse!(%{})
    build_context(language, module_name, api_spec, doc_spec, options)
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
  def function_parameters(action) do
    Enum.join([join_parameters(action.url_parameters),
               join_header_parameters(action)])
  end

  defp join_header_parameters(action) do
    if action.method == "GET" do
      join_parameters(action.request_header_parameters, nil)
    else
      ""
    end
  end

  defp join_parameters(parameters, default \\ nil) do
    Enum.join(Enum.map(parameters,
          fn(parameter) ->
            if default == nil do
              ", #{parameter.code_name}"
            else
              ", #{parameter.code_name} \\\\ #{inspect(default)}"
            end
          end))
  end

  defp build_context(language, module_name, api_spec, doc_spec, options) do
    actions = collect_actions(language, api_spec, doc_spec)
    signing_name = case api_spec["metadata"]["signingName"] do
     nil -> api_spec["metadata"]["endpointPrefix"]
     sn   -> sn
      end
    %Service{actions: actions,
      docstring: Docstring.format(language, doc_spec["service"]),
      signing_name: signing_name,
      endpoint_prefix: api_spec["metadata"]["endpointPrefix"],
      json_version: api_spec["metadata"]["jsonVersion"],
      module_name: module_name,
      protocol: api_spec["metadata"]["protocol"],
      target_prefix: api_spec["metadata"]["targetPrefix"],
             options: options}
  end

  defp collect_actions(language, api_spec, doc_spec) do
    Enum.map(api_spec["operations"], fn({operation, _metadata}) ->
      url_parameters = collect_url_parameters(language, api_spec, operation)
      request_header_parameters = collect_request_header_parameters(language, api_spec, operation)
      method = api_spec["operations"][operation]["http"]["method"]
      arity = length(url_parameters) + if(method == "GET", do: 2 + length(request_header_parameters), else: 3)
      %Action{
        arity: arity,
        docstring: Docstring.format(language,
                                          doc_spec["operations"][operation]),
        method: method,
        request_uri: api_spec["operations"][operation]["http"]["requestUri"],
        success_status_code: api_spec["operations"][operation]["http"]["responseCode"],
        function_name: AWS.CodeGen.Name.to_snake_case(operation),
        name: operation,
        url_parameters: url_parameters,
        request_header_parameters: request_header_parameters,
        response_header_parameters: collect_response_header_parameters(language, api_spec, operation),
        language: language
      }
    end)
    |> Enum.sort(fn(a, b) -> a.function_name < b.function_name end)
  end

  defp collect_url_parameters(language, api_spec, operation) do
    shape_name = api_spec["operations"][operation]["input"]["shape"]
    if shape_name do
      shape = api_spec["shapes"][shape_name]

      shape["members"]
      |> Enum.filter(filter_fn("uri"))
      |> Enum.map(fn x -> build_parameter(language, x) end)
    else
      []
    end
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
      nil ->
        []

      ^shape ->
        shape["members"]
        |> Enum.filter(filter_fn("header"))
        |> Enum.map(fn x -> build_parameter(language, x) end)
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

  defp build_parameter(language, {name, data}) do
    %Parameter{
      code_name: if language == :elixir do
        AWS.CodeGen.Name.to_snake_case(name)
      else
        AWS.CodeGen.Name.upcase_first(name)
      end,
      name: name,
      location_name: data["locationName"]
    }
  end
end
