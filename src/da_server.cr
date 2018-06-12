
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
    @user = "www-deployer",
    handlers : Array(HTTP::Handler) = [] of HTTP::Handler
  )
    @server = HTTP::Server.new(
      @host,
      @port,
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

    DA.orange! "=== Binding on: #{port}"
    server.bind(false)
    DA.orange! "=== Starting server for: #{host}:#{port}"

    if !ENV["IS_DEVELOPMENT"]? && `whoami`.strip != user
      DA.orange! "=== Switching to user: #{user}"
      self.class.switch_user(user)
    end
    server.listen(false)
  end # === def listen

end # === module DA_Server
