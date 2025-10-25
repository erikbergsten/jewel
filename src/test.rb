require 'tty-command'

cmd = TTY::Command.new

expr = "radius = 3
height = 3
volume = (1.0/3) * Math::PI * radius**2 * height
volume"

res = cmd.ruby("-e", expr)

puts "result: #{res.stdout}"
