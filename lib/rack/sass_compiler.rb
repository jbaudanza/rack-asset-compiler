require 'rack/asset_compiler'
require 'helpers/hash_recursive_merge'
require 'sass'

module Rack
  class SassCompiler < AssetCompiler
    attr_accessor :sass_options

    def initialize(app, options={})
      options

      options = {
        :url => '/stylesheets',
        :content_type => 'text/css',
        :sass_options => {
          :syntax => :scss,
          :cache  => false
        }
      }.rmerge(options)

      @sass_options = options[:sass_options]
      options[:source_extension] ||= @sass_options[:syntax].to_s
      super
    end

    def get_load_paths(src_dir)
      [src_dir]
    end

    def compile(source_file)
      @sass_options[:load_paths] ||= []
      @sass_options[:load_paths]   = @sass_options[:load_paths] | get_load_paths(source_dir)
      Sass::Engine.new(::File.read(source_file), @sass_options).render
    end
  end
end
