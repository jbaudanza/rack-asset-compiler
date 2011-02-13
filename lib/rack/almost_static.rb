module Rack
  class AlmostStatic
    attr_accessor :urls, :source_dir, :source_extension

    F = ::File

    def initialize(app, options={}, &block)
      @app = app

      # XXX: Make these required?
      @compiler = options[:compiler] || block
      @source_dir = options[:source_dir] || Dir.pwd
      @source_extension = options[:source_extension]
      @urls = options[:urls]
    end

    def response(status, body, content_type='text/plain')
      [status, {"Content-Type" => content_type,
           "Content-Length" => body.size.to_s},
           [body]]
    end

    def compile(source_file)
      if @compiler
        @compiler.call(source_file)
      else
        ''
      end
    end

    def call(env)
      request_path = Utils.unescape(env["PATH_INFO"])
      return response( 403, "Forbidden: #{request_path}\n" ) if request_path.include? ".."

      urls.each do |url|
        match_parts = url.split('/')
        request_parts = request_path.split('/')

        if(request_parts.take(match_parts.length) == match_parts)
          request_base = request_parts[match_parts.length..-1]

          # Swap in the source file extension
          request_base[-1].sub!(/\.\w+$/, '.' + source_extension)

          source_file = F.join(source_dir, request_base)
          if F.exists?(source_file)
            body = compile(source_file)
            return response(200, body, 'text/chicken-script')
          end
        end
      end

      @app.call(env)
    end
  end
end
