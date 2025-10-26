# frozen_string_literal: true

require 'pastel'
require_relative 'chat'
require_relative 'ui'

$pastel = Pastel.new

# Define a hash of available commands and their corresponding methods
COMMANDS = {
  "help" => :display_help,
  "reset" => :reset_chat,
  "debug" => :display_history,
  "exit" => :exit_program
}.freeze

# --- Command Handler Functions ---

def display_help
  puts "\n--- Available Commands ---"
  COMMANDS.keys.each do |command|
    case command
    when "help"
      puts "  /help   - Display this list of commands."
    when "exit"
      puts "  /exit   - Terminate the program."
    when "reset"
      puts "  /reset   - Reset the chat history."
    when "debug"
      puts "  /debug   - Show the entire chat history."
    end
  end
  puts "--------------------------\n"
end

def exit_program
  puts "\nGoodbye! 👋"
  exit # Stops the program execution
end

def send_to_llm(input)
  # In a real application, this is where you would integrate with an LLM API.
  # puts "\n[LLM] Received request: \"#{input}\""
  # puts "[LLM] Thinking... (Simulated Response: 'That is a great question!')"
  return ask_ai(input)
end

# --- Main Interactive Loop ---

def interactive_shell
  puts "🤖 Welcome to the LLM Chat Shell."
  puts "Type a message to send to the LLM, or use /help for commands."
  puts "Press Ctrl+D or type /exit to quit.\n"

  loop do
    # 1. READ: Prompt the user for input
    print $pastel.bold("Prompt:\n> ")

    # Use gets and immediately check for nil (Ctrl+D)
    input_with_newline = gets

    # Handle Ctrl+D (EOF) by calling the exit function
    unless input_with_newline
      exit_program 
    end

    input = input_with_newline.chomp.strip

    # Skip if input is empty after stripping whitespace
    next if input.empty?

    # 2. EVAL: Check if the input is a command
    if input.start_with?('/')
      # Remove the leading '/' and check against the command hash keys
      command_key = input[1..].downcase

      if COMMANDS.key?(command_key)
        # Call the corresponding function (method)
        send(COMMANDS[command_key])
      else
        puts "\nUnknown command: #{input}. Use /help for a list of commands."
      end
    else
      # 3. EVAL: If not a command, send the string to the LLM function
      res = ask_ai(input)

      fmt = "\n# Response (#{res.input_tokens}/#{res.output_tokens} tokens):\n\n#{res.content}\n\n"
      UI.puts_md fmt
    end
  end
end

# --- Main Entrypoint: Single Command Mode or Interactive ---
if ARGV[0] == '-c' && ARGV[1]
  input = ARGV[1].strip
  if input.start_with?('/')
    command_key = input[1..].downcase
    if COMMANDS.key?(command_key)
      send(COMMANDS[command_key])
    else
      puts "\nUnknown command: #{input}. Use /help for a list of commands."
    end
  else
    print $pastel.bold("Prompt:\n> ")
    puts input
    res = ask_ai(input)
    fmt = "\n# Response (#{res.input_tokens}/#{res.output_tokens} tokens):\n\n#{res.content}\n\n"
    UI.puts_md fmt
  end
else
  interactive_shell
end
