require 'pastel'
require 'tty-markdown'
require 'tty-screen'
require 'tty-prompt'

$prompt = TTY::Prompt.new
$pastel = Pastel.new

module UI
  def confirm(prompt: "Proceed?")
    $prompt.yes?(prompt)
  end

  def error(message)
    puts $pastel.red.bold(message)
  end

  def warn(message)
    puts $pastel.yellow.bold(message)
  end

  def puts_md(md)
    parsed = TTY::Markdown.parse(md, width: TTY::Screen.size[1], indent: 2, symbols: {
      override: {
        bullet: "-"
      }
    })
    puts parsed
  end

  def puts_line
    parsed = TTY::Markdown.parse("***", width: TTY::Screen.size[1])
    puts parsed
  end

  module_function :confirm, :error, :warn, :puts_md, :puts_line
end
