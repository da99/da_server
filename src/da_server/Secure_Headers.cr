
struct DA_Server
  class Secure_Headers

    include HTTP::Handler

    def call(ctx)
      ctx.response.headers["Content-Security-Policy"] = "script-src 'self';"
      ctx.response.headers["X-XSS-Protection"]        = "1; mode=block"
      ctx.response.headers["X-Frame-Options"]         = "SAMEORIGIN;"
      ctx.response.headers["X-Content-Type"]          = "nosniff"
      ctx.response.headers["X-DNS-Prefetch-Control"]  = "off"

      call_next(ctx)
    end # === def call

  end # === struct Secure_Headers
end # === module DA_Server
