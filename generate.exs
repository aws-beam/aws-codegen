[module_name, api_spec_path, doc_spec_path, template_path] = System.argv
context = AWS.CodeGen.load_context(module_name, api_spec_path, doc_spec_path)
IO.puts AWS.CodeGen.render(context, template_path)
