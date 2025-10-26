# JEWEL

AI assistant in the terminal using [RubyLLM](https://rubyllm.com/) and [TTY toolkit](https://ttytoolkit.org/).


## Capabilities

The prompt includes all files in your current git project (as found using the git ls-files function in [git](https://github.com/ruby-git/ruby-git)).

Jewel has access to these tools:

  * Reading a file
  * Writing file
  * Evaluating a ruby expression
  * Running a ruby script

All tool calls will ask for user permission before executing.

Jewel can theoretically read any file but is only aware of the ones commited to git.

Whenever jewel attempts to write a file a diff created with [diffy](https://github.com/samg/diffy) will be displayed before asking for your confirmation.

## Usage

Set `MY_SECRET_API_KEY` and add add this function to your .bashrc to use jewel
in your terminal:

    jewel() {
      podman run -it --rm -e OPENAI_API_KEY=$MY_SECRET_API_KEY -v $PWD:/work jewel:latest "$@"
    }

## Development

Set `MY_SECRET_API_KEY` and start a dev environmnet using the script "dev.sh"
