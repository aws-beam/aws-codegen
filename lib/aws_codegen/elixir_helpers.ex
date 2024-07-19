defmodule AWS.CodeGen.ElixirHelpers do
  alias AWS.CodeGen.PostService
  alias AWS.CodeGen.RestService
  require EEx

  @validate_quoted EEx.compile_string(~s{
    # Validate optional parameters
    optional_params = [<%= Enum.map(action.optional_query_parameters ++ action.optional_request_header_parameters ++ action.request_headers_parameters, &(&1.code_name <> ": nil")) |> Enum.join(", ") %>]
    options = Keyword.validate!(options, [enable_retries?: false, retry_num: 0, retry_opts: []] ++ optional_params)
  })
  def define_and_validate_optionals(action) do
    {res, _} = Code.eval_quoted(@validate_quoted, action: action)
    res
  end

  @drop_optionals_quoted EEx.compile_string(~s{
    # Drop optionals that have been moved to query/header-params
    options = options
      |> Keyword.drop([<%= action.optional_query_parameters ++ action.optional_request_header_parameters |> Enum.map(fn act -> ":" <> act.code_name end) |> Enum.join(", ") %>])
      })
  def drop_optionals(action) do
    if Enum.empty?(action.optional_query_parameters) and
         Enum.empty?(action.optional_request_header_parameters) do
      # Don't drop anything, if there are no optional params
      nil
    else
      # Drop the optional params
      {res, _} = Code.eval_quoted(@drop_optionals_quoted, action: action)
      res
    end
  end

  def render_type_fields(_type_name, type_fields, indent \\ 4) do
    indent_str = String.duplicate(" ", indent)

    Enum.map_join(type_fields, ",\n" <> indent_str, fn {field_name, field_type} ->
      field_name <> field_type
    end)
  end

  @docstring_rest_quoted EEx.compile_string(~s{
  <%= if String.trim(action.docstring) != "" do %>
    @doc """
    <%= action.docstring %>

    [API Reference](<%= action.docs_url %>)

    ## Parameters:<%= for parameter <- action.url_parameters do %>
    <%= AWS.CodeGen.render_parameter(:elixir, parameter) %><% end
    %><%= for parameter <- action.required_query_parameters do %>
    <%= AWS.CodeGen.render_parameter(:elixir, parameter) %><% end
    %><%= for parameter <- action.required_request_header_parameters do %>
    <%= AWS.CodeGen.render_parameter(:elixir, parameter) %><% end
    %><%= if action.send_body_as_binary? do %>
    * `:input` (`t:binary<%= if action.body_required? do %> | nil<% end %>`)
    <% else %><%= if action.has_body? do %>
    * `:input` (`t:map<%= if action.body_required? do %> | nil<% end %>`):<%= for parameter <- action.required_body_parameters do %>
      <%= AWS.CodeGen.render_parameter(:elixir, parameter) %><% end
      %><%= for parameter <- action.optional_body_parameters do %>
      <%= AWS.CodeGen.render_parameter(:elixir, parameter) %><% end
    %><% end
    %><% end %>

    ## Optional parameters:<%= for parameter <- action.optional_query_parameters do %>
    <%= AWS.CodeGen.render_parameter(:elixir, parameter) %><% end
    %><%= for parameter <- action.optional_request_header_parameters do %>
    <%= AWS.CodeGen.render_parameter(:elixir, parameter) %><% end %>
    """<% end %>
  })
  def render_docstring(%RestService.Action{} = action, _context, _types) do
    {res, _} = Code.eval_quoted(@docstring_rest_quoted, action: action)
    res
  end

  @docstring_post_quoted EEx.compile_string(~s/
  <%= if String.trim(action.docstring) != "" do %>
     @doc """
     <%= action.docstring %>

    [API Reference](<%= action.docs_url %>)

     ## Parameters:
     * `:input` (`t:<%= input_type %>`):
       %{
         <%= AWS.CodeGen.ElixirHelpers.render_type_fields(input_type, type_fields, 9) %>
       }
     """<% end %>/)
  def render_docstring(%PostService.Action{} = action, context, types) do
    input_type =
      AWS.CodeGen.Types.function_argument_type(:elixir, action)
      # TODO: This is dirty.
      |> String.split("(")
      |> hd()

    type_fields =
      types[input_type]

    {res, _} =
      Code.eval_quoted(@docstring_post_quoted,
        action: action,
        input_type: input_type,
        type_fields: type_fields
      )

    res
  end

  def render_guards(action) do
    required_params =
      action.required_query_parameters ++ action.required_request_header_parameters

    body_guard =
      cond do
        action.send_body_as_binary? and action.body_required? ->
          "is_binary(input)"

        action.send_body_as_binary? and not action.body_required? ->
          "is_binary(input)"

        action.has_body? ->
          "is_map(input) or is_nil(input)"

        action.has_body? and action.body_required? ->
          "is_map(input)"

        action.has_body? and not action.body_required? ->
          "is_map(input) or is_nil(input)"

        true ->
          ""
      end

    req_guards =
      required_params
      |> Enum.map(fn param ->
        case param.type do
          "integer" ->
            "is_integer(#{param.code_name})"

          "long" ->
            "is_integer(#{param.code_name})"

          "string" ->
            "is_binary(#{param.code_name})"

          "list[" <> _ ->
            "is_binary(#{param.code_name})"
        end
      end)
      |> Enum.join(" and ")

    cond do
      body_guard == "" and req_guards == "" ->
        ""

      body_guard == "" ->
        "when " <> req_guards

      req_guards == "" ->
        "when " <> body_guard

      true ->
        "when (" <> body_guard <> ") and " <> req_guards
    end
  end
end
