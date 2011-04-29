Gem::Specification.new do |s|
  s.name = 'rack-asset-compiler'
  s.version = "0.2.1"
  s.author = 'Jonathan Baudanza'
  s.email = 'jon@jonb.org'
  s.summary = 'Rack Middleware to facilitate the generic compiling static assets.'
  s.homepage = 'http://www.github.com/jbaudanza/rack-asset-compiler'
  s.add_dependency 'rack'
  s.files =  [ "rack-asset-compiler.gemspec", "Rakefile", "README.md", "LICENSE.txt" ]
  s.files += Dir['lib/rack/*.rb'] + Dir['spec/**/*']
  s.files += [ "examples/jasmine_config.rb" ]
  
  s.description = <<END
rack-asset-compiler is a Rack middleware that provides a generic interface for compiling static files, such as Sass or CoffeeScript files.

rack-asset-compiler does not use any local file storage and makes use of caching headers such as "Cache-Control" and "If-Modified-Since".  This makes it ideal for running on read-only filesystem systems such as Heroku.  
END
end
