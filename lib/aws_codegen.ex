defmodule AWS.CodeGen do
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

    defstruct abbreviation: nil,
              actions: [],
              api_version: nil,
              credential_scope: nil,
              content_type: nil,
              docstring: nil,
              decode: nil,
              encode: nil,
              endpoint_prefix: nil,
              is_global: false,
              json_version: nil,
              module_name: nil,
              protocol: nil,
              signature_version: nil,
              service_id: nil,
              signing_name: nil,
              target_prefix: nil
  end

  # Configuration map which determines what AWS API protocols have an
  # implementation for what language.
  @configuration %{
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

    Enum.each(tasks, fn task -> Task.await(task) end)
  end

  defp generate_code(spec, language, endpoints_spec, template_base_path, output_path) do
    template = @configuration[spec.protocol][:template][language]

    if template do
      protocol_service = @configuration[spec.protocol][:module]
      template_path = Path.join(template_base_path, template)

      context = protocol_service.load_context(language, spec, endpoints_spec)
      code = protocol_service.render(context, template_path)

      IO.puts(["Writing ", spec.module_name, " to ", output_path])

      code =
        if language == :elixir do
          Code.format_string!(code)
        else
          code
        end

      File.write(output_path, code)
    else
      IO.puts("Failed to generate #{spec.module_name}, protocol #{spec.protocol}")
    end
  end

  @spec api_specs(binary(), :elixir | :erlang) :: [Spec.t()]
  defp api_specs(base_path, language) do
    search_path = Path.join(base_path, "*/*")
    IO.puts("Parsing specs in #{search_path}")

    for path <- Path.wildcard(search_path) do
      Spec.parse(path, language)
    end
  end

  defp get_endpoints_spec(base_path) do
    Path.join([base_path, "..", "endpoints", "endpoints.json"])
    |> Spec.parse_json()
    |> get_in(["partitions"])
    |> Enum.filter(fn x -> x["partition"] == "aws" end)
    |> List.first()
  end
end
