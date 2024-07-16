defmodule AWS.CodeGen.ElixirHelpers do
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
end
