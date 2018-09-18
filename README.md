# rack-asset-compiler

rack-asset-compiler is a Rack middleware that provides a generic interface for compiling static files, such as Sass or CoffeeScript files.

rack-asset-compiler does not use any local file storage and makes use of caching headers such as "Cache-Control" and "If-Modified-Since".  This makes it ideal for running on read-only filesystem systems such as Heroku.

## Installation

    gem install rack-asset-compiler

## Generic form

In this example, we have a set of text files with the extension .lower in the 'lowercase' directory, and
we want to serve .uppercase files out of http://yourhost.com/uppercase

The compilation step is given in the form of a lambda passed as the `:compiler` option.  This lambda will
be invoked whenever a client requests a file that needs to be compiled.  The source filename will be passed
in and the compiled output is expected to be returned.

    require 'rack/asset_compiler'

    use Rack::AssetCompiler,
      :source_dir => 'lowercase',
      :url => '/uppercase',
      :content_type => 'text/plain',
      :source_extension => 'lower',
      :compiler => lambda { |source_file|
        File.read(source_file).upcase
      }

## Subclassing
An alternative to passing in a lambda to the :compiler option is to subclass Rack::AssetCompiler and
override the `compile` method.

This gem comes with two subclasses: one for compiling CoffeeScript and one for compiling Sass.

## Compiling CoffeeScript

config.ru

    require 'rack/coffee_compiler'

    use Rack::CoffeeCompiler,
      :source_dir => 'app/coffeescripts',
      :url => '/javascripts',
      :alert_on_error => true  # Generates a window.alert on compile error.  Defaults to (RACK_ENV != 'production')

Gemfile

    gem 'therubyracer'
    gem 'coffee-script'

See [examples/jasmine_config.rb](https://github.com/jbaudanza/rack-asset-compiler/tree/master/examples/jasmine_config.rb) for an example of how to use CoffeeScript with your jasmine specs.

## Compiling Sass

On Rails

    require 'rack/sass_compiler'

    # Disable the standard Sass plugin which will write to the filesystem
    Rails.application.config.middleware.delete(Sass::Plugin::Rack)

    # Insert the new middleware
    Rails.application.config.middleware.use Rack::SassCompiler,
      :source_dir => 'app/sass',
      :url => '/css'

The above uses the default options for the sass compiler, including the
use of the scss syntax. To compile sass, or to change any of the other
sass compiler options, provide the optional `sass_options` hash in the
options hash. For example...

    # Insert the new middleware
    Rails.application.config.middleware.use Rack::SassCompiler,
      :source_dir => 'app/sass',
      :url => '/css'
      :sass_options => {
        :syntax => :sass,
        :style => :compressed
      }

The above would use the sass syntax compiler and output compressed
CSS. See [Sass Documentation](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#options)
for a list of options.

To make the Compass frameworks available to the SassCompiler, simply
require Compass and any compass plugins. For example...

    require 'compass'
    require 'ninesixty' # 960.gs Compass plugin 

    use Rack::SassCompiler,
      :source_dir => 'sass'
      :url => '/css'


## Running without an HTTP cache
If your stack doesn't include an HTTP cache (like Varnish), the compilation step will run each time a new visitor requests a compiled resource.

An easy solution is to use [Rack::Cache][rack-cache]

    require 'rack/asset_compiler'
    require 'rack/cache'
    use Rack::Cache # Make sure this comes first
    use Rack::AssetCompiler, ...

If you're deploying to the Bamboo or Aspen stack on Heroku, you get Varnish for free.  The Cedar stack on
Heroku does not have Varnish, so you'll have to use Rack::Cache and/or something like [Cloudfront](http://aws.amazon.com/cloudfront/).

If you're running locally, the user agent cache in your browser is sufficient.  So you also don't need to worry about this.

## Contribute

Contributions must be accompanied by passing tests. To run the test suite for
 the gem you need the following gems installed:

    [sudo] gem install rack rack-test haml coffee-script rspec compass

After installing the required gems and before beginning development,
ensure your environment is properly configured and all tests pass by
running `rake`.

## Thanks
asset-compiler was inspired by [rack-coffee] by [Matthew Lyon][mattly]

ruby 1.9.2 compatibility added by [Derek Prior][derekprior]

[rack-coffee]: https://github.com/mattly/rack-coffee
[mattly]: https://github.com/mattly
[derekprior]: https://github.com/derekprior
[rack-cache]: http://rtomayko.github.com/rack-cache/
