
require "inspect_bang"
require "../src/da_server"

full_cmd = ARGV.map(&.strip).join(' ')

case
when full_cmd == "test public files"
  # === {{CMD}} test public files

  DA_Server.new(
    host: "localhost",
    port: 4567,
    user: `whoami`.strip,
    handlers: [
      DA_Server::No_Slash_Tail.new(302),
      DA_Server::Public_Files.new("./Public")
    ]
  ).listen

else
  STDERR.puts "!!! Unknown command: #{full_cmd}"
  exit 2
end # === case full_cmd
