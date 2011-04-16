require 'rack/asset_compiler'
require 'compass'

module Rack
  class CompassCompiler < AssetCompiler
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

    def compile(source_file)
      compass_paths = []
      Compass::Frameworks::ALL.each do |framework|
        compass_paths << framework.stylesheets_directory if ::File.exists?(framework.stylesheets_directory)
      end
      sass_options = {
        :syntax => syntax,
        :cache => false,
        :load_paths => [source_dir] + compass_paths
      }
      Sass::Engine.new(::File.read(source_file), sass_options).render
    end
  end
end
