
require "http/server"
require "da"
require "./da_server/Secure_Headers"

lib LibC
  fun setuid(uid_t : Int)
  fun getuid : Int
end

struct DA_Server

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

  def listen
    bin_name = File.basename(Process.executable_path.not_nil!)
    old_procs = `pgrep -f "#{bin_name} service run"`.strip
    if !old_procs.empty?
      DA.exit_with_error!("!!! Found other processes: #{bin_name} service run: #{old_procs.split.join ' '}")
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
