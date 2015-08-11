[spec_path, template_path, output_path] = System.argv
AWS.CodeGen.generate(:elixir, spec_path, template_path, output_path)
