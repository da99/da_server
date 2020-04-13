require "uri"

struct DA_Server
  class Public_Files
    include HTTP::Handler

    getter dir : String
    METHODS = "GET HEAD".split

    def initialize(raw_dir : String)
      @dir = File.expand_path(raw_dir)
      if !File.directory?(@dir)
        raise Exception.new("Not a directory: #{raw_dir}")
      end
    end

    def call(ctx)
      method = ctx.request.method
      return call_next(ctx) if !METHODS.includes?(method)

      path = ctx.request.path.not_nil!

      # Ignore if any unusual characters are found:
      return call_next(ctx) if path[%r{[^/a-z\.\-_\+\^\~0-9]+$}]?

      expanded  = File.expand_path(path, "/")
      file_path = File.join(dir, path)

      if path != expanded && File.exists?(file_path)
        return redirect_to(ctx, expanded)
      end

      if Dir.exists?(file_path) # /dir -> /dir/index.html
        file_path = File.join(file_path, "index.html")
      else # /file -> /file.html
        _temp = "#{file_path}.html"
        if File.file?(_temp)
          file_path = _temp
        end
      end

      return call_next(ctx) if !File.file?(file_path)

      last_modified = File.info(file_path).modification_time
      ctx.response.headers["Last-Modified"] = HTTP.format_time(last_modified)
      if_modified_since = ctx.request.headers["If-Modified-Since"]?

        if if_modified_since
          header_time = HTTP.parse_time(if_modified_since)

          if header_time && last_modified <= header_time + 1.second
            ctx.response.status_code = 304
            return
          end
      end

      ctx.response.content_type = DA_Server.mime(file_path)
      ctx.response.content_length = File.size(file_path)
      File.open(file_path) do |file|
        IO.copy(file, ctx.response)
      end
    end # === def call

    # given a full path of the request, returns the path
    # of the file that should be expanded at the public_dir
    protected def request_path(path : String) : String
      path
    end

    private def redirect_to(ctx, url)
      ctx.response.status_code = 302
      ctx.response.headers["Location"] = begin
                                           _io = IO::Memory.new
                                           URI.encode(url, _io) { |byte|
                                             URI.unreserved?(byte) || byte.chr == '/'
                                           }
                                           _io.to_s
                                         end
      ctx
    end

  end # === class Public_Files

end # === module DA_Server
