require 'rack/asset_compiler'
require 'sass'

module Rack
  class SassCompiler < AssetCompiler
    attr_accessor :syntax

    def initialize(app, options={})
      options

      options = {
        :url => '/stylesheets',
        :content_type => 'text/css',
        :syntax => :scss
      }.merge(options)

      @syntax = options[:syntax]
      options[:source_extension] ||= syntax.to_s
      super
    end

    def get_load_paths(src_dir)
      [src_dir]
    end

    def compile(source_file)
      sass_options = {
        :syntax => syntax,
        :cache => false,
        :load_paths => get_load_paths(source_dir)
      }
      Sass::Engine.new(::File.read(source_file), sass_options).render
    end
  end
end
