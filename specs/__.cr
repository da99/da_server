
require "da_spec"

require "../src/da_server"

extend DA_SPEC

describe "new(Array(HTTP::Handlers))" do

  it "sets host" do
    s = DA_Server.new([HTTP::StaticFileHandler.new("Public", false)])
    assert s.host == "127.0.0.1"
  end # === it "sets host"

  it "sets port" do
    s = DA_Server.new([HTTP::StaticFileHandler.new("Public", false)])
    assert s.port == 4567
  end # === it "sets port"

  it "sets server" do
    s = DA_Server.new([HTTP::StaticFileHandler.new("Public", false)])
    assert s.server.is_a?(HTTP::Server) == true
  end # === it "sets server"

end # === desc "new"

describe "new(host, port, Array(HTTP::Handlers))" do

  it "sets host" do
    s = DA_Server.new("1.1.1.1", 123, [HTTP::StaticFileHandler.new("Public", false)])
    assert s.host == "1.1.1.1"
  end # === it "sets host"

  it "sets port" do
    s = DA_Server.new("2.2.2.2", 222, [HTTP::StaticFileHandler.new("Public", false)])
    assert s.port == 222
  end # === it "sets port"

  it "sets server" do
    s = DA_Server.new("44.4.4.4", 444, [HTTP::StaticFileHandler.new("Public", false)])
    assert s.server.is_a?(HTTP::Server) == true
  end # === it "sets server"

end # === desc "new"
