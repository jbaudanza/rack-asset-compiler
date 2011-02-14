require 'rack/asset_compiler'
require 'coffee-script'

module Rack
  class CoffeeCompiler < AssetCompiler
    def initialize(app, options={})
      options[:url] ||= '/javascripts'
      options[:content_type] ||= 'text/javascript'
      options[:source_extension] ||= 'coffee'
      @alert_on_error = options.has_key?(:alert_on_error) ? options[:alert_on_error] : ENV['RACK_ENV'] != 'production'
      super
    end

    def compile(source_file)
     begin
        CoffeeScript.compile(::File.read(source_file))
      rescue CoffeeScript::CompilationError => e
        if @alert_on_error
          error_msg = "CoffeeScript compilation error in #{source_file}.coffee:\n\n #{e.to_s}"
          "window.alert(#{error_msg.to_json});"
        else
          raise e
        end
      end
    end
  end
end