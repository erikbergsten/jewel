require 'ruby_llm'
require 'diffy'
require 'git'
require 'tty-command'
require_relative 'ui'

RubyLLM.configure do |cfg|
  cfg.openai_api_key = ENV.fetch('OPENAI_API_KEY', nil)
end

$cmd = TTY::Command.new

class RubyEval < RubyLLM::Tool
  description "Runs a ruby script using \"ruby -e\" and returns the output"
  param :code, desc: "the code to execute"
  def execute(code:)
    UI::warn "Trying to eval:\n#{code}"
    if UI::confirm
      return eval code
    else
      return "permission denied"
    end
  rescue => e
    UI::error e.message
    { error: e.message }
  end
end

class RubyScript < RubyLLM::Tool
  description "Runs a ruby script from the users system"
  param :path, desc: "path to the script"
  def execute(path:)
    UI::warn "Trying to run: #{path}"
    if UI::confirm
      result = $cmd.ruby(path)
      return result.stdout
    else
      return "permission denied"
    end
  rescue => e
    UI::error e.message
    { error: e.message }
  end
end

class FileReader < RubyLLM::Tool
  description "Reads a file from the users system."
  param :path, desc: "path to the file"
  def execute(path:)
    UI::warn "Trying to read #{path}"
    if UI::confirm
      return File.read(path)
    else
      return "permission denied"
    end
  rescue => e
    UI::error e.message
    { error: e.message }
  end
end

class FileWriter < RubyLLM::Tool
  description "Writes contents to a file on the users system."
  param :path, desc: "path to the file"
  param :content, desc: "the contents of the file"
  def execute(path:, content:)
    UI::warn "Trying to write #{path}"
    old_content = ""
    if File.file? path
      old_content = File.read(path)
    end
    puts Diffy::Diff.new(old_content, content).to_s(:color)
    if UI::confirm
      File.write(path, content)
      return "ok"
    else
      return "permission denied"
    end
  rescue => e
    UI::error e.message
    return e.message
  end
end

$ruby_eval = RubyEval.new
$ruby_script = RubyScript.new
$reader = FileReader.new
$writer = FileWriter.new

$g = Git.open(".")
def reset_chat
  files = $g.ls_files.keys.to_s
  $instructions = """You are a helpful coding assistant. When asked to perform complicated mathematical or programming tasks use the ruby language and the provided tools. The list of files on the users system is: #{files}"""
  $chat = RubyLLM.chat(model: "gpt-4.1").with_tools($reader, $writer, $ruby_eval, $ruby_script).with_instructions $instructions
end

reset_chat

def ask_ai(prompt)
  response = $chat.ask prompt
  return response
end

def display_history
  pp $chat.messages
end
