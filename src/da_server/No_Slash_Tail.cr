
struct DA_Server

  class No_Slash_Tail

    include HTTP::Handler

    getter redirect_code
    def initialize(@redirect_code = 302)
    end # === def initialize

    def call(ctx)
      path = ctx.request.path

      if path.size > 2 && path.ends_with?('/') && !path.includes?('?')
        new_path = path.chomp('/')
        return DA_Server.redirect_to(redirect_code, new_path, ctx)
      end

      return call_next(ctx)
    end # === def call

  end # === class No_Slash_Tail

end # === struct DA_Server
