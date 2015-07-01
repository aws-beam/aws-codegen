[name, spec_path, template_path] = System.argv
context = AWS.CodeGen.RestJSONService.load_context(name, spec_path)
IO.puts AWS.CodeGen.RestJSONService.render(context, template_path)
