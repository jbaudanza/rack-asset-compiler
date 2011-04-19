module Rack
  class AssetCompiler
    attr_accessor :url, :source_dir, :source_extension

    F = ::File

    def initialize(app, options={}, &block)
      @app = app

      options = {
        :compiler => block,
        :source_dir => Dir.pwd,
        :url => '/',
        :cache => ENV['RACK_ENV'] == 'production'
      }.merge(options)

      %w(source_extension content_type).each do |field|
        raise "Missing required option :#{field}" unless options.has_key?(field.to_sym)
      end

      @compiler = options[:compiler]
      @source_dir = options[:source_dir]
      @url = options[:url]
      @source_extension = options[:source_extension]
      @content_type = options[:content_type]

      @cache_ttl = options[:cache]

      # Default cache duration is 1 week
      if(@cache_ttl && !@cache_ttl.kind_of?(Integer))
        @cache_ttl = 60 * 60 * 24 * 7
      end
    end

    def response(status, body)
      body += "\r\n"
      [status, {"Content-Type" => 'text/plain',
           "Content-Length" => body.size.to_s},
           [body]]
    end

    def compile(source_file)
      if @compiler
        @compiler.call(source_file)
      else
        raise "Missing compiler"
      end
    end

    def call(env)
      request_path = Utils.unescape(env["PATH_INFO"])
      return response( 403, 'Forbidden') if request_path.include? ".."

      match_parts = url.split('/').select{ |str| str.length > 0 }
      request_parts = request_path.split('/').select{ |str| str.length > 0 }

      if(request_parts.take(match_parts.length) == match_parts)
        request_base = request_parts[match_parts.length..-1]

        # Directory listsings not supported
        return response( 403, 'Forbidden') if F.directory? F.join(source_dir, request_base)

        # Swap in the source file extension
        request_base[-1].sub!(/\.\w+$/, '.' + source_extension)
        source_file = F.join(source_dir, request_base)

        if F.exists?(source_file)
          last_modified_time = F.mtime(source_file)

          if env['HTTP_IF_MODIFIED_SINCE']
            cached_time = Time.parse(env['HTTP_IF_MODIFIED_SINCE'])
            if last_modified_time <= cached_time
              return [304, {}, ["Not modified\r\n"]]
            end
          end

          body = compile(source_file)

          headers = {
            'Content-Type' => @content_type,
            'Content-Length' => body.length.to_s,
            'Last-Modified' => last_modified_time.httpdate
          }

          if @cache_ttl
            headers['Expires'] = (Time.now + @cache_ttl).strftime('%a, %d %b %Y %H:%M:%S GMT')
            headers['Cache-Control'] = "public,max-age=#{@cache_ttl}"
          end

          return [200, headers, [body]]
        end
      end

      @app.call(env)
    end
  end
end
