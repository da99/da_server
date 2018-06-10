
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

  def used_ports(i : Int32)
    results = [] of String
    `ss -anp`.split('\n').each { |l|
      pieces = l.split
      if pieces[4]? && pieces[4][/:#{i}$/]?
          results << pieces.join(' ')
      end
    }
    results
  end

  def listen
    used = used_ports(port)
    if !used.empty?
      STDERR.puts "!!! Found other processes using port #{port}:"
      used.each { |l|
        STDERR.puts l
      }
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
