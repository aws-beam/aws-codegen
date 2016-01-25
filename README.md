[![Build Status](https://travis-ci.org/jkakar/aws-codegen.svg?branch=master)](https://travis-ci.org/jkakar/aws-codegen)

Code generator for AWS clients in Elixir.

## Generating code

The code generator uses API specs defined in the
[AWS SDK for Go](https://github.com/aws/aws-sdk-go) to generate Erlang and
Elixir clients for AWS services.  Code is generated by running the
`generate.exs` script for Elixir:

```bash
export SPEC_PATH=../../awslabs/aws-sdk-go/models/apis
export TEMPLATE_PATH=priv
export OUTPUT_PATH=../aws-elixir/lib/aws
>>>>>>> master
mix run generate.exs elixir $SPEC_PATH $TEMPLATE_PATH $OUTPUT_PATH
```

and for Erlang:

```bash
export SPEC_PATH=../../awslabs/aws-sdk-go/models/apis
export TEMPLATE_PATH=priv
export OUTPUT_PATH=../aws-erlang/src
mix run generate.exs erlang $SPEC_PATH $TEMPLATE_PATH $OUTPUT_PATH
```
