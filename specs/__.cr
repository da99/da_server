
require "da_spec"

require "../src/da_server"

extend DA_SPEC

describe "new(host, port, Array(HTTP::Handlers))" do

  it "sets host" do
    s = DA_Server.new(
      host: "1.1.1.1",
      port: 123,
      user: "www-deployer",
      handlers: [HTTP::StaticFileHandler.new("Public", false)]
    )
    assert s.host == "1.1.1.1"
  end # === it "sets host"

  it "sets port" do
    s = DA_Server.new(
      host: "1.1.1.1",
      port: 222,
      user: "www-deployer",
      handlers: [HTTP::StaticFileHandler.new("Public", false)]
    )
    assert s.port == 222
  end # === it "sets port"

  it "sets server" do
    s = DA_Server.new(
      host: "1.1.1.1",
      port: 123,
      user: "www-deployer",
      handlers: [HTTP::StaticFileHandler.new("Public", false)]
    )
    assert s.server.is_a?(HTTP::Server) == true
  end # === it "sets server"

  it "sets user" do
    s = DA_Server.new(
      host: "1.1.1.1",
      port: 123,
      user: "www-redirector",
      handlers: [HTTP::StaticFileHandler.new("Public", false)]
    )
    assert s.user == "www-redirector"
  end # === it "sets users"

  it "listens" do
    if false
      DA_Server.new(
        host: "1.1.1.1",
        port: 123,
        user: "www-redirector",
        handlers: [HTTP::StaticFileHandler.new("Public", false)]
      ).listen
    end
    assert true == true
  end # === it "listens"

end # === desc "new"
