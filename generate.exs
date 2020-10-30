language = Enum.at(System.argv, 0)
unless Enum.member?(["elixir", "erlang"], language) do
  raise """
  Please, specify either elixir or erlang in the first argument:

    mix run generate.exs elixir

  or, for erlang:

    mix run generate.exs erlang
  """
end

spec_path = Enum.at(System.argv, 1, "../aws-sdk-go/models/apis")
if !File.dir?(spec_path) do
  raise """
  Could not find the specification files under #{spec_path}!

  Either specify the correct path in the second argument:

     mix run generate.exs #{language} /path/to/aws-sdk-go/models/apis

  or clone the AWS SDK with:

     git clone git@github.com:aws/aws-sdk-go.git ../aws-sdk-go

  and try again.
  """
end
template_path = Enum.at(System.argv, 2, "priv")
if !File.dir?(template_path) do
  raise """
  Template path "#{template_path}" could not be found!

  Please, specify the correct path in the third argument:

     mix run generate.exs #{language} #{spec_path} /path/to/template_path

  and try again.
  """
end
output_path = Enum.at(System.argv, 3, "../aws-#{language}/lib/aws/generated")
if !File.dir?(output_path) do
  raise """
  The aws-#{language} project could not be found at path "#{output_path}"!

  Please, specify the correct path in the last argument:

     mix run generate.exs #{language} #{spec_path} #{template_path} /path/to/aws-#{language}/lib/aws/generated

  and try again.
  """
end

IO.puts("""
Generating code with the following parameters:

Language: #{language}
Specification Path: #{spec_path}
Templates Path: #{template_path}
Output Path: #{output_path}
""")

AWS.CodeGen.generate(String.to_atom(language), spec_path, template_path, output_path)
