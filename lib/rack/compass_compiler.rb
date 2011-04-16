require 'rack/sass_compiler'
require 'compass'

module Rack
  class CompassCompiler < SassCompiler

    def get_load_paths(src_dir)
      paths = [src_dir]
      Compass::Frameworks::ALL.each do |framework|
        paths << framework.stylesheets_directory if ::File.exists?(framework.stylesheets_directory)
      end
      paths
    end

  end
end
