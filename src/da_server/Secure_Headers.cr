
struct DA_Server
  class Secure_Headers

    include HTTP::Handler

    SAFE_METHODS = [
      "GET",
      "HEAD",
      "OPTIONS",
      "TRACE",
    ]

    def call(ctx)
      new_path                         = clean_path(ctx.request.path)
      if new_path.includes?('\0')
        ctx.response.status_code = 400
        return
      end

      ctx.request.path                 = new_path
      ctx.request.headers["PATH_INFO"] = new_path

      user_agent = ctx.request.headers.fetch("User-Agent", "").downcase
      old_msie = user_agent[/msie\s+\d\s/]?
      outdated_browser = case
                         when old_msie
                           true
                         else
                           false
                         end

      ctx.response.headers["Content-Security-Policy"] = "script-src 'self'; frame-ancestors 'none'; default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';"
      ctx.response.headers["X-Frame-Options"]         = "DENY;"
      ctx.response.headers["X-Content-Type"]          = "nosniff"
      ctx.response.headers["X-Content-Type-Options"]  = "nosniff"
      ctx.response.headers["X-DNS-Prefetch-Control"]  = "off"
      ctx.response.headers["X-Download-Options"]      = "noopen"

      if outdated_browser
        if old_msie
          ctx.response.headers["X-XSS-Protection"] = "0"
        end
        ctx.response.status_code = 404
        ctx.response << "Your browser is too old. Please update it to view this site."
        return ctx
      end

      ctx.response.headers["X-XSS-Protection"]        = "1; mode=block"

      if !SAFE_METHODS.includes?(ctx.request.method.upcase)
        origin = ctx.request.headers["Origin"]? || ctx.request.headers["HTTP_ORIGIN"]? || ctx.request.headers["HTTP_X_ORIGIN"]?
        host = ctx.request.headers["Host"]
        uri = origin ? URI.parse(origin) : nil
        return forbidden(ctx, "Invalid origin.") if !origin || !host
        return forbidden(ctx, "Invalid origin.") if !(uri && uri.host && uri.host == host)
      end

      # strict transport security needed:
      # https://github.com/EvanHahn/crystal-helmet/blob/637aa46e497bfce4c84bfdd6b913816f5a171b38/src/helmet/stricttransportsecurityhandler.cr

      call_next(ctx)
    end # === def call


    def clean_path(path : String)
      path.gsub(%r{(%2e|\.)+}i, '.').gsub(%r{(%2f|/)+}i, '/')
    end

    def forbidden(ctx, msg = "Invalid request.")
      ctx.response.status_code = 403
      ctx.response << "Invalid request."
      ctx
    end # === def forbidden

  end # === struct Secure_Headers
end # === module DA_Server
