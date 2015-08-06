[module_name, api_spec_path, doc_spec_path, template_path] = System.argv
context = AWS.CodeGen.RestJSONService.load_context(module_name, api_spec_path,
                                                   doc_spec_path)
IO.puts AWS.CodeGen.RestJSONService.render(context, template_path)
