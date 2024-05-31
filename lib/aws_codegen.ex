defmodule AWS.CodeGen do
  alias AWS.CodeGen.RestService.Parameter
  alias AWS.CodeGen.Spec

  @moduledoc """
  AWS API Services generator.

  Generates the AWS client modules for the `aws-beam/aws-erlang` and
  `aws-beam/aws-elixir` projects.

  Maintains a global `@configuration` that specifies what protocols
  are implemented for which target language (`:erlang` or `:elixir`).

  The services that will be generated is discovered by finding all
  available specs in the provided `spec_base_path` and then checking
  if there is an available implementation for that protocol.
  """

  defmodule Service do
    @moduledoc false

    defstruct actions: [],
              api_version: nil,
              credential_scope: nil,
              content_type: nil,
              docstring: nil,
              decode: nil,
              encode: nil,
              endpoint_prefix: nil,
              is_global: false,
              hostname: nil,
              json_version: nil,
              language: nil,
              module_name: nil,
              protocol: nil,
              signature_version: nil,
              service_id: nil,
              shapes: %{},
              signing_name: nil,
              target_prefix: nil
  end

  # Configuration map which determines what AWS API protocols have an
  # implementation for what language.
  @configuration %{
    ec2: %{
      module: AWS.CodeGen.PostService,
      template: %{
        elixir: "post.ex.eex",
        erlang: "post.erl.eex"
      }
    },
    json: %{
      module: AWS.CodeGen.PostService,
      template: %{
        elixir: "post.ex.eex",
        erlang: "post.erl.eex"
      }
    },
    rest_json: %{
      module: AWS.CodeGen.RestService,
      template: %{
        elixir: "rest.ex.eex",
        erlang: "rest.erl.eex"
      }
    },
    query: %{
      module: AWS.CodeGen.PostService,
      template: %{
        elixir: "post.ex.eex",
        erlang: "post.erl.eex"
      }
    },
    rest_xml: %{
      module: AWS.CodeGen.RestService,
      template: %{
        elixir: "rest.ex.eex",
        erlang: "rest.erl.eex"
      }
    }
  }

  @doc """
  Entrypoint for the code generation.
  """
  @spec generate(:elixir | :erlang, binary(), binary(), binary()) :: :ok
  def generate(language, spec_base_path, template_base_path, output_base_path) do
    endpoints_spec = get_endpoints_spec(spec_base_path)

    tasks =
      Enum.map(
        api_specs(spec_base_path, language),
        fn spec ->
          output_path = Path.join(output_base_path, spec.filename)

          Task.async(fn ->
            generate_code(spec, language, endpoints_spec, template_base_path, output_path)
          end)
        end
      )

    Enum.each(tasks, fn task -> Task.await(task, 120_000) end)
  end

  defp generate_code(spec, language, endpoints_spec, template_base_path, output_path) do
    template = @configuration[spec.protocol][:template][language]

    if template do
      protocol_service = @configuration[spec.protocol][:module]
      template_path = Path.join(template_base_path, template)

      context = protocol_service.load_context(language, spec, endpoints_spec)

      case Map.get(context, :actions) do
        [] ->
          IO.puts(["Skipping ", spec.module_name, " due to no actions"])

        _ ->
          code = render(context, template_path)

          IO.puts(["Writing ", spec.module_name, " to ", output_path])

          File.write(output_path, code)
      end
    else
      IO.puts("Failed to generate #{spec.module_name}, protocol #{spec.protocol}")
    end
  end

  def render(context, template_path) do
    rendered = EEx.eval_file(template_path, context: context)

    format_string!(context.language, rendered)
  end

  @param_quoted_elixir EEx.compile_string(
                         ~s|* `:<%= parameter.code_name %>` (`t:<%= parameter.type %>`) <%= parameter.docs %>|
                       )
  def render_parameter(:elixir, %Parameter{} = parameter) do
    Code.eval_quoted(@param_quoted_elixir, parameter: parameter)
    |> then(&elem(&1, 0))
    |> Excribe.format(width: 80, hanging: 4, pretty: true)
  end

  defp format_string!(:elixir, rendered) do
    [Code.format_string!(rendered), ?\n]
  end

  # TODO: format using the new Erlang formatter:
  # https://tech.nextroll.com/blog/dev/2020/02/25/erlang-rebar3-format.html
  defp format_string!(_, rendered) do
    rendered
  end

  @spec api_specs(binary(), :elixir | :erlang) :: [Spec.t()]
  defp api_specs(base_path, language) do
    search_path = Path.join(base_path, "*")
    IO.puts("Parsing specs in #{search_path}")

    for file <- Path.wildcard(search_path) do
      Spec.parse(file, language)
    end
  end

  defp get_endpoints_spec(base_path) do
    Path.join([
      base_path,
      "../../",
      "smithy-aws-go-codegen/src/main/resources/software/amazon/smithy/aws/go/codegen",
      "endpoints.json"
    ])
    |> Spec.parse_json()
    |> get_in(["partitions"])
    |> Enum.filter(fn x -> x["partition"] == "aws" end)
    |> List.first()
  end
end
