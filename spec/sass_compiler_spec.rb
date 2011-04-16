require 'rack/sass_compiler'
require 'rack/lobster'
require "rack/test"

include Rack::Test::Methods

describe "SassCompiler" do
  before do
    @source_dir = File.join(File.dirname(__FILE__), 'fixtures/sass')

    @options = {
      :source_dir => @source_dir
    }
  end

  def app
    options = @options
    Rack::Builder.new {
      use Rack::Lint
      use Rack::SassCompiler, options
      run Rack::Lobster.new
    }
  end

  it "should compile scss" do
    get '/stylesheets/style.css'
    last_response.body.should ==
      Sass::Engine.new(File.read("#{@source_dir}/style.scss"), :syntax => :scss).render
    last_response.status.should == 200
    last_response.content_type.should == 'text/css'
  end

  it "should compile sass" do
    @options[:sass_options] = {:syntax => :sass}
    get '/stylesheets/style.css'
    last_response.body.should ==
      Sass::Engine.new(File.read("#{@source_dir}/style.sass"), :syntax => :sass).render
    last_response.status.should == 200
    last_response.content_type.should == 'text/css'
  end
end
