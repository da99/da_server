
require "http/server"
require "da"

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
  getter user   : String = "www-deployer"
  getter server : HTTP::Server

  def initialize(*args)
    @host = ENV["IS_DEVELOPMENT"]? ? "127.0.0.1" : "0.0.0.0"
    @port = ENV["IS_DEVELOPMENT"]? ? 4567 : 80
    @server = HTTP::Server.new(@host, @port, *args)
  end # === def initialize

  def initialize(@host, @port, *args)
    @host = ENV["IS_DEVELOPMENT"]? ? "127.0.0.1" : "0.0.0.0"
    @port = ENV["IS_DEVELOPMENT"]? ? 4567 : 80
    @server = HTTP::Server.new(@host, @port, *args)
  end # === def initialize

  def listen
    server.bind
    if !ENV["IS_DEVELOPMENT"]? && `whoami`.strip != user
      self.class.switch_user(user)
    end
    server.listen
  end # === def listen

end # === module DA_Server
