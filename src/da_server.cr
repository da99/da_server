
require "http/server"
require "da"
require "./da_server/File_Types"
require "./da_server/No_Slash_Tail"
require "./da_server/Public_Files"
require "./da_server/Secure_Headers"

lib LibC
  fun setuid(uid_t : Int)
  fun getuid : Int
end

struct DA_Server

  def self.redirect_to(code : Int32, path : String, ctx)
    ctx.response.status_code = code
    ctx.response.headers["Location"] = path
    ctx
  end # === def redirect_to

  def self.mime(path)
    FILE_TYPES[File.extname(path)]? || "application/octet-stream"
  end

  def self.switch_user(user : String)
    new_id = `id -u #{user}`.strip
    if new_id.empty?
      DA.exit_with_error!("#{user} id not found")
    end
    LibC.setuid new_id.to_i32
  end

  getter host   : String
  getter port   : Int32
  getter user   : String
  getter server : HTTP::Server

  def initialize(
    @host = "127.0.0.1",
    @port = 4567,
    @user = `whoami`.strip,
    handlers : Array(HTTP::Handler) = [] of HTTP::Handler
  )
    if !@user[/^[a-z0-9A-Z\.\-\_]+$/]
      raise Exception.new("Invalid user: #{@user.inspect}")
    end

    @server = HTTP::Server.new(
      ([Secure_Headers.new] of HTTP::Handler).concat(handlers)
    )
  end # === def initialize

  def used_ports
    `ss --no-header -lnp -o state listening '( sport = :#{port} )'`.strip
  end

  def listen
    ports = used_ports
    if !ports.empty?
      STDERR.puts "!!! Found other processes using port #{port}:"
      STDERR.puts ports
      exit 1
    end

    DA.orange! "=== Binding on: #{host}:#{port}"
    server.bind_tcp host, port

    if !DA.is_development? && `whoami`.strip != user
      DA.orange! "=== Switching to user: #{user}"
      self.class.switch_user(user)
    end

    server.listen
  end # === def listen

end # === module DA_Server
