[language, spec_path, template_path, output_path] = System.argv
AWS.CodeGen.generate(String.to_atom(language), spec_path, template_path,
                     output_path)
