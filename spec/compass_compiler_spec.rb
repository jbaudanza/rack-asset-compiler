require 'rack/compass_compiler'
require 'rack/lobster'
require "rack/test"

include Rack::Test::Methods

describe "CompassCompiler" do
  before do
    @source_dir = File.join(File.dirname(__FILE__), 'fixtures/compass')

    @options = {
      :source_dir => @source_dir
    }
  end

  def app
    options = @options
    Rack::Builder.new {
      use Rack::Lint
      use Rack::CompassCompiler, options
      run Rack::Lobster.new
    }
  end

  it "should compile compass" do
    get '/stylesheets/compass.css'
    last_response.status.should == 200
    last_response.content_type.should == 'text/css'
  end
end
