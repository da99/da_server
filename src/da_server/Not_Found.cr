
class Not_Found
  include HTTP::Handler
  def initialize
  end # def

  def call(ctx)
    ctx.response.status_code = 404
    ctx.response.content_type = "text/plain"
    ctx.response.print "404 NOT FOUND: #{ ctx.request.path.inspect  }"
  end # def
end # class
