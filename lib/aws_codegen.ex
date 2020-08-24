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

  # Configuration map which determines what AWS API protocols have an
  # implementation for what language.
  @configuration %{
    :json => %{
      :module => AWS.CodeGen.PostService,
      :template => %{
        :elixir => "post.ex.eex",
        :erlang => "post.erl.eex"
      }
    },
    :rest_json => %{
      :module => AWS.CodeGen.RestService,
      :template => %{
        :elixir => "rest.ex.eex",
        :erlang => "rest.erl.eex"
      }
    },
    :query => %{
      :module => AWS.CodeGen.PostService,
      :template => %{
        :elixir => "post.ex.eex",
        :erlang => "post.erl.eex"
      }
    },
    :rest_xml => %{
      :module => AWS.CodeGen.RestService,
      :template => %{
        :elixir => "rest.ex.eex",
        :erlang => "rest.erl.eex"
      }
    }
  }

  @doc """
  Entrypoint for the code generation.
  """
  def generate(language, spec_base_path, template_base_path, output_base_path) do
    endpoints_spec = get_endpoints_spec(spec_base_path)
    tasks = Enum.map(api_specs(spec_base_path, language),
      fn(spec) ->
        output_path = Path.join(output_base_path, spec.filename)
        args = [spec, language, endpoints_spec, template_base_path, output_path]
        Task.async(AWS.CodeGen, :generate_code, args)
      end)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
  end

  @doc """
  Generate code for a specific API using `spec`.

  Called throuhg Task.async/3.
  """
  def generate_code(spec, language, endpoints_spec, template_base_path, output_path) do
    template = @configuration[spec.protocol][:template][language]
    if not is_nil(template) do
      protocol_service = @configuration[spec.protocol][:module]
      template_path = Path.join(template_base_path, template)
      args = [language, spec.module_name, endpoints_spec, spec.api, spec.doc]
      context = apply(protocol_service, :load_context, args)
      code = apply(protocol_service, :render, [context, template_path])
      IO.puts(["Writing ", spec.module_name, " to ", output_path])
      File.write(output_path, code)
    else
      IO.puts("Failed to generate #{spec.module_name}, protocol #{Atom.to_string(spec.protocol)}")
    end
  end

  defp api_specs(base_path, language) do
    search_path = Path.join(base_path, "*/*")
    IO.puts("Parsing specs in #{search_path}")
    for path <- Path.wildcard(search_path) do
      Spec.parse(path, language)
    end
  end

  defp get_endpoints_spec(base_path) do
    Path.join([base_path, "..", "endpoints", "endpoints.json"])
    |> Spec.parse_json
    |> get_in(["partitions"])
    |> Enum.filter(fn(x) -> x["partition"] == "aws" end)
    |> List.first
  end

end
