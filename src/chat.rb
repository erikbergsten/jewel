require 'ruby_llm'
require 'diffy'
require 'git'
require_relative 'ui'


RubyLLM.configure do |cfg|
  cfg.openai_api_key = ENV.fetch('OPENAI_API_KEY', nil)
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

$reader = FileReader.new
$writer = FileWriter.new

$g = Git.open(".")
def reset_chat
  files = $g.ls_files.keys.to_s
  $instructions = """You are a helpful coding assistant. You have the ability to read and write files. The list of files on the users system is: #{files}"""
  $chat = RubyLLM.chat(model: "gpt-4.1").with_tools($reader, $writer).with_instructions $instructions
end

reset_chat


def ask_ai(prompt)
  response = $chat.ask prompt
  return response
end

def display_history
  pp $chat.messages
end
