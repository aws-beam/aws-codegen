[service_description_path, template_path] = System.argv
context = AWS.CodeGen.load_context(service_description_path)
IO.puts AWS.CodeGen.render(context, template_path)
