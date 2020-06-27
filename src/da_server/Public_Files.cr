require "uri"

struct DA_Server
  class Public_Files
    include HTTP::Handler

    getter dirs : Array(String)
    METHODS = "GET HEAD".split

    def initialize(*raw_dirs : String)
      @dirs = raw_dirs.map { |raw|
        File.join(Dir.current, File.expand_path(s, "/"))
      }
    end

    def call(ctx)
      method = ctx.request.method
      return call_next(ctx) if !METHODS.includes?(method)

      raw_path = ctx.request.path.not_nil!

      # Ignore if any unusual characters are found:
      return call_next(ctx) if raw_path[%r{[^/a-z\.\-_\+\^\~0-9]+$}]?

      # Check if path is relative. Example: ./index.html
      # Redirect to expanded path if possible:
      expanded  = File.expand_path(raw_path, "/")
      if raw_path != expanded
        return redirect_to(ctx, expanded)
      end

      file_path = nil
      dirs.find { |dir|
        file_path = find_www_file(File.join dir, expanded)
        file_path
      } # dirs.each
      return call_next(ctx) if !file_path

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

    # Given an absolute path, returns a file:
    # /dir -> /dir/index.html
    # /dir/file -> /dir/file.html
    # /file.ext -> /file.ext
    protected def find_www_file(file_path : String) : String?
      # Return if file_path is a file.
      return file_path if File.file?(file_path)

      # /dir -> /dir/index.html
      if Dir.exists?(file_path)
        _temp = File.join(file_path, "index.html")
        return _temp if File.file?(_temp)
      end

      # /file -> /file.html
      _temp = "#{file_path}.html"
      return _temp if File.file?(_temp)
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
