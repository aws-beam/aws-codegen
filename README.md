[![Actions Status](https://github.com/aws-beam/aws-codegen/workflows/Build/badge.svg)](https://github.com/aws-beam/aws-codegen/actions)

Code generator for Elixir and Erlang AWS client.

## Generating code

The code generator uses specs from the [AWS SDK v2 for the Go programming
language][aws-sdk-go-v2] to generate code.

Code is generated by running the `generate.exs` script. It requires Elixir 1.8.4+.

### Elixir

```bash
export SPEC_PATH=../../aws/aws-sdk-go-v2/codegen/sdk-codegen/aws-models
export TEMPLATE_PATH=priv
export ELIXIR_OUTPUT_PATH=../aws-elixir/lib/aws/generated
mix run generate.exs elixir $SPEC_PATH $TEMPLATE_PATH $ELIXIR_OUTPUT_PATH
```

### Erlang

```bash
export SPEC_PATH=../../aws/aws-sdk-go-v2/codegen/sdk-codegen/aws-models
export TEMPLATE_PATH=priv
export ERLANG_OUTPUT_PATH=../aws-erlang/src
mix run generate.exs erlang $SPEC_PATH $TEMPLATE_PATH $ERLANG_OUTPUT_PATH
```

## AWS Protocols

Each AWS API uses a specific protocol which is defined in its
specification JSON file in the [aws-sdk-go-v2][] repository. The existing
protocols are:

- json
- rest-json
- query
- rest-xml

Every one of these protocols uses HTTP in an asynchronous (request &
response) fashion. They mostly differ in what `Content-Type` they use
for the request body, whether they include parameters in the URL or in
the headers, and what `Content-Type` should one expect in the
response body.

The following table attempts to capture the specifics of each protocol:

|                         | json               | rest-json                               | query                               | rest-xml                                |
|-------------------------|--------------------|-----------------------------------------|-------------------------------------|-----------------------------------------|
| Methods                 | `POST`             | `GET`, `POST`, `PATCH`, `PUT`, `DELETE` | `POST`                              | `GET`, `POST`, `PATCH`, `PUT`, `DELETE` |
| Request `Content-Type`  | `application/json` | `application/json`                      | `application/x-www-form-urlencoded` | `text/xml`                              |
| URL Parameters          | No                 | Yes                                     | No                                  | Yes                                     |
| Header Parameters       | No                 | Yes                                     | No                                  | Yes                                     |
| Response `Content-Type` | `application/json` | `application/json`                      | `text/xml`                          | `text/xml`                              |

## Dependencies

This project has some dependencies you need to install before installing
packages with Hex. Here you can find instructions for Ubuntu Linux and Mac OS.

### Ubuntu Linux dependencies

Two packages are needed for Ubuntu: `gcc` and `build-essential`. To install them:

    $ apt-get install build-essential cmake

### Mac OS X dependencies

Two similar packages are needed in OS X, but you may install them with [brew][]:

    $ brew install gcc cmake

Alternatively you can install XCode's Command Line Developer Tools package:

    $ xcode-select --install

[aws-sdk-go-v2]: https://github.com/aws/aws-sdk-go-v2
[brew]: https://brew.sh/
